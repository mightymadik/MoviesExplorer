//
//  MovieDetailOverviewCollectionViewCell.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import UIKit

class MovieDetailOverviewCollectionViewCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProDisplay-Regular", size: 16)
        label.textColor = .white
        label.text = "Overview"
        label.numberOfLines = 15
        label.textAlignment = .left
        return label
    }()
    
    func configure(movieDetail: MovieDetailModel) {
        titleLabel.text = movieDetail.overview
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
