//
//  FPSMonitor.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/17.
//

import QuartzCore
import Combine

class FPSMonitor: ObservableObject {
    @Published var fps: Int = 0
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    
    func start() {
        // 建立 DisplayLink，目標對象為 self
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        // 將其加入到 RunLoop 中 (common 模式可確保在滑動時也能更新)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func handleDisplayLink(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        
        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        
        // 每隔一秒更新一次數值，避免 UILabel 跳動太快
        if delta >= 1.0 {
            fps = Int(round(Double(frameCount) / delta))
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
