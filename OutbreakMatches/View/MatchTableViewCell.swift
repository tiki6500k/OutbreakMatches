// 
//  MatchTableViewCell.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    var match: Match? {
        didSet {
            guard let match = match else { return }
            
            print("🥸", "\(match.id)",
                  "[\(match.teamA)]", match.teamAOdds,
                  "[\(match.teamB)]", match.teamBOdds)
            
            matchIDLabel.text = "\(match.id)"
            dateLabel.text = match.startTime.iso8601
            homeTeamLabel.text = match.teamA
            awayTeamLabel.text = match.teamB
            
            if homeTeamOddsLabel.text != match.teamAOdds.formattedNumber() {
                homeTeamOddsLabel.shake()
            }
            homeTeamOddsLabel.text = "\(match.teamAOdds.formattedNumber())"
            
            if awayTeamOddsLabel.text != match.teamBOdds.formattedNumber() {
                awayTeamOddsLabel.shake()
            }
            awayTeamOddsLabel.text = "\(match.teamBOdds.formattedNumber())"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let matchIDLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let homeTeamContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let homeTeamLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let homeTeamOddsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let awayTeamContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let awayTeamLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let awayTeamOddsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        
        return label
    }()
}

private extension MatchTableViewCell {
    func setupUI() {
        setupMatchIDLabel()
        setupDateLabel()
        
        setupHomeTeamContainerView()
        setupHomeTeamLabel()
        setupHomeTeamOddsLabel()
        
        setupAwayTeamContainerView()
        setupAwayTeamLabel()
        setupAwayTeamOddsLabel()
    }
    
    func setupMatchIDLabel() {
        contentView.addSubview(matchIDLabel)
        
        matchIDLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview()
        }
    }
    
    func setupDateLabel() {
        contentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(matchIDLabel.snp.trailing).offset(12)
            make.centerY.equalTo(matchIDLabel)
        }
    }
    
    func setupHomeTeamContainerView() {
        contentView.addSubview(homeTeamContainerView)
        
        homeTeamContainerView.snp.makeConstraints { make in
            make.top.equalTo(matchIDLabel.snp.bottom).offset(12)
            make.leading.bottom.equalToSuperview()
        }
    }
    
    func setupHomeTeamLabel() {
        homeTeamContainerView.addSubview(homeTeamLabel)
        
        homeTeamLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    func setupHomeTeamOddsLabel() {
        homeTeamContainerView.addSubview(homeTeamOddsLabel)
        
        homeTeamOddsLabel.snp.makeConstraints { make in
            make.leading.equalTo(homeTeamLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(homeTeamLabel)
        }
    }
    
    func setupAwayTeamContainerView() {
        contentView.addSubview(awayTeamContainerView)
        
        awayTeamContainerView.snp.makeConstraints { make in
            make.top.bottom.equalTo(homeTeamContainerView)
            make.trailing.equalToSuperview().inset(12)
        }
    }
    
    func setupAwayTeamLabel() {
        awayTeamContainerView.addSubview(awayTeamLabel)
        
        
        awayTeamLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
    }
    
    func setupAwayTeamOddsLabel() {
        awayTeamContainerView.addSubview(awayTeamOddsLabel)
        
        awayTeamOddsLabel.snp.makeConstraints { make in
            make.leading.equalTo(awayTeamLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(awayTeamLabel)
        }
    }
}

private extension MatchTableViewCell {
    func bind() {
        //
    }
}
