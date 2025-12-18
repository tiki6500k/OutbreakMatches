//
//  ViewController.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import UIKit
import SnapKit
import Combine

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fpsMonitor.stop()
    }
    
    private let viewModel = MatchViewModel()
    
    // 檢測 FPS
    private let fpsMonitor = FPSMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "Matches"
        
        return label
    }()
    
    private let fpsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label.withAlphaComponent(0.6)
        label.text = "--"
        
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

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MatchTableViewCell.use(table: tableView, for: indexPath)
        
        cell.match = viewModel.match(at: indexPath.row)
        
        return cell
    }
}

private extension MainViewController {
    func setupUI() {
        setupStackView()
        setupHeaderContainerView()
        setupTitleLabel()
        setupFpsLabel()
        setupTableView()
    }
    func setupStackView() {
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
    }
    
    func setupHeaderContainerView() {
        stackView.addArrangedSubview(headerContainerView)
    }
    
    func setupTitleLabel() {
        headerContainerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
    }
    
    func setupFpsLabel() {
        headerContainerView.addSubview(fpsLabel)
        
        fpsLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        stackView.addArrangedSubview(tableView)
    }
}


private extension MainViewController {
    func bind() {
        viewModel.onInitialLoad = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onOddsUpdate = { [weak self] indexPath in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        fpsMonitor.$fps
            .receive(on: RunLoop.main)
            .map { "\($0) FPS" }
            .assign(to: \.text, on: fpsLabel)
            .store(in: &cancellables)
        
        fpsMonitor.start()
    }
}
