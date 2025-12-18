# iOS 即時賽事賠率系統－架構說明文件

## 一、專案目標

本專案旨在實作一個使用 **UIKit + MVVM** 架構的即時賽事賠率顯示 App，整合 Mock REST API 與 WebSocket 推播，並在高頻更新情境下維持 UI 流暢度與資料一致性。

重點目標如下：
- 顯示約 100 筆賽事資料，依比賽時間升序排序
- 即時接收賠率更新（每秒最多 10 筆）並更新對應 cell
- 確保多執行緒下的資料存取安全
- 畫面切換與 App 重啟後可快速恢復顯示（快取機制）
- 維持良好效能並避免不必要的整頁重載

---

## 二、整體架構概覽

本專案採用 **MVVM（Model–View–ViewModel）** 架構，並搭配 Swift Concurrency 與 Actor 進行非同步與 thread-safe 資料處理。

```
View (UIViewController / UITableViewCell)
   ↕ (同步讀取 View State)
ViewModel
   ↕ (async / Task)
Store (Actor, thread-safe)
   ↕
Service / Cache / WebSocket
```

設計原則：
- View 僅負責顯示與使用者互動
- ViewModel 管理畫面狀態、資料整合與更新策略
- Actor 負責所有可變資料的 thread-safe 存取
- Service 與 Cache 各司其職，避免職責混雜

---

## 三、資料模型（Model）

- **Match**：代表單一賽事的 domain model，包含隊伍、開賽時間與即時賠率
- **OddsUpdate**：WebSocket 推播用的賠率更新資料

`Match` 為不可變結構（更新時以新值覆蓋），並實作 `Codable` 以支援 disk cache 序列化。

---

## 四、資料來源與即時更新設計

### 1. REST API（Mock）

- `/matches`：回傳約 100 筆賽事基本資料
- `/odds`：回傳各場比賽的初始賠率

ViewModel 在初始化時同時取得並整合上述資料，建立初始賽事列表。

### 2. WebSocket（模擬）

- 使用 `Task` 模擬 WebSocket 行為
- 每秒最多推播 10 筆隨機賠率更新
- 每筆更新僅影響單一賽事

ViewModel 僅更新受影響的資料並通知 View 進行對應 cell 更新，避免整頁 reload。

---

## 五、Thread-Safe 資料處理

為避免高頻即時更新造成 race condition，本專案使用 **Swift Concurrency + Actor** 管理所有可變賽事資料。

### MatchStore（Actor）

- 內部以 Dictionary 儲存所有賽事資料
- 所有寫入（賠率更新）與讀取（排序後列表）皆透過 Actor 進行
- 對外僅提供 async API

此設計可確保在多 Task 同時更新賠率時，資料始終維持一致狀態，且無需手動 lock。

---

## 六、ViewModel 與 UI 資料綁定策略

### 1. 同步 View State

由於 UIKit 的 `UITableViewDataSource` 為同步介面，本專案在 ViewModel 中維護一份 **同步可讀的畫面狀態（cachedMatches）**。

- 非同步更新僅發生於資料變動階段
- UI 永遠只讀取已準備完成的狀態
- 避免在 DataSource 中使用 `Task` 或 semaphore

### 2. UI 更新策略

- 初始載入：`reloadData()`
- 賠率更新：僅 `reloadRows(at:)` 更新對應 cell

此策略可大幅降低 layout 與 rendering 成本，確保高頻更新下仍能順暢捲動。

---

## 七、快取機制（Disk + Memory Hybrid Cache）

為支援畫面快速恢復與 App 冷啟動，本專案實作 **Memory + Disk 混合快取策略**。

### 快取層級

1. **Memory Cache**：
   - App 尚存活時使用
   - 畫面切換可立即顯示資料

2. **Disk Cache（JSON）**：
   - App 被殺掉後仍可還原
   - 使用 `cachesDirectory` 儲存
   - 搭配 TTL 避免使用過期資料

### 快取資料內容

- 儲存已排序完成的賽事列表（View State）
- 包含儲存時間（savedAt）作為過期判斷依據

### 冷啟動還原流程

1. 嘗試從 Memory Cache 讀取
2. Memory miss → 嘗試從 Disk Cache 讀取
3. Disk hit 時，同時：
   - 還原 UI 顯示
   - 將資料重新注入 Actor，確保後續即時更新可正確套用
4. Cache miss 或過期 → 重新打 API

---

## 八、WebSocket 斷線自動重連

考量 WebSocket 為不可靠連線，本專案於 ViewModel 中實作連線生命週期管理與自動重連策略。

### 設計重點

- 僅允許單一 WebSocket 連線存在
- 斷線後自動重連
- 採用 Exponential Backoff（指數退避）避免過度重試

重連策略屬於業務層決策，因此由 ViewModel 管理，而非放入 WebSocket Service 中。

---

## 九、效能監測（Performance Monitoring）

為驗證在高頻即時賠率更新情境下的 UI 流暢度，本專案額外實作一個 FPS 監測工具，用以觀察畫面更新對效能的實際影響。

該工具基於 `CADisplayLink` 實作，透過計算單位時間內的畫面刷新次數，即時顯示目前 FPS 值。FPS 數值僅作為效能觀測用途，並未參與任何業務邏輯或資料流程。

在架構設計上，此監測元件刻意與 MVVM 架構解耦：

- 僅由 ViewController 持有與啟動
- 不依賴 ViewModel 狀態
- 不影響資料更新、排序或快取行為
- 不介入 UI rendering 流程

透過此方式，可在開發與驗證階段確認即時更新對畫面流暢度的影響，並確保效能符合需求。

---

## 十、設計取捨與說明

- 使用 UIKit 而非 SwiftUI，以取得更可控的 cell 更新與效能表現
- 使用 Actor 取代傳統 lock，提升可讀性與安全性
- 將快取與 WebSocket 策略集中於 ViewModel，避免 ViewController 複雜化
- 將效能監測視為開發輔助工具，而非業務功能

---

## 十一、總結

本專案在符合題目所有功能需求的前提下，著重於：
- 架構清晰與責任分離
- 高頻即時更新下的效能與穩定性
- 可擴充的快取與連線管理設計

整體設計可輕易延伸至真實 API、正式 WebSocket、或更大型的賽事資料規模。

