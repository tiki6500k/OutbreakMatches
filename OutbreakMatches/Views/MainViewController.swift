//
//  ViewController.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "Matches"
        
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.register(MatchTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
    }()
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MatchTableViewCell.use(table: tableView, for: indexPath)
        
        return cell
    }
}

private extension MainViewController {
    func setupUI() {
        setupStackView()
        setupTitleLabel()
        setupTableView()
    }
    
    func setupStackView() {
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
    }
    
    func setupTitleLabel() {
        stackView.addArrangedSubview(titleLabel)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        stackView.addArrangedSubview(tableView)
    }
}


private extension MainViewController {
    func bind() {
        
    }
}
