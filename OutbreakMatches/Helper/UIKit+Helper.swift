//
//  TableViewCell+Helper.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import UIKit

extension UITableView {
    // Register cell
    func register(_ cellClass: AnyClass...) {
        cellClass.forEach {
            self.register($0, forCellReuseIdentifier: String(describing: $0))
        }
    }
}

extension UITableViewCell {
    static func use(table view: UITableView, for index: IndexPath) -> Self {
        return cell(tableView: view, for: index)
    }

    private static func cell(tableView: UITableView, for index: IndexPath) -> Self {

        let id = String(describing: self)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: index) as? Self else {
            assert(false)
            return .init()
        }

        return cell
    }
}

extension UILabel {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3 // 0.3 section for animation
        
        animation.values = [0, -5, 5, -5, 5, -2, 2, 0]
        
        self.layer.add(animation, forKey: "shake")
    }
}
