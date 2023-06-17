//
//  SectionHeaderCollectionReusableView.swift
//  Movies Explorer
//
//  Created by MacBook on 10.06.2023.
//

import Foundation
import UIKit

protocol SectionHeaderCollectionReusableViewDelegate: AnyObject {
    func didSeeAllButtonTapped(moviesCategory: MoviesCategory)
}

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    weak var delegate: SectionHeaderCollectionReusableViewDelegate?
    
    private var moviesCategory: MoviesCategory?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("See all", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.init(red: 181/255 , green: 178/255, blue: 178/255, alpha: 1), for:  .normal )
        return button
    }()
    
    
    
    func configure(title: String, moviesCategory: MoviesCategory) {
        titleLabel.text = title
        self.moviesCategory = moviesCategory
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(seeAllButton)
        NSLayoutConstraint.activate([
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            seeAllButton.widthAnchor.constraint(equalToConstant: 66),
            seeAllButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        seeAllButton.addTarget(self, action: #selector(seeAll), for: .touchUpInside)
    }
    
    @objc
    private func seeAll() {
        guard let moviesCategory = moviesCategory else { return }
        delegate?.didSeeAllButtonTapped(moviesCategory: moviesCategory )
    }
}
