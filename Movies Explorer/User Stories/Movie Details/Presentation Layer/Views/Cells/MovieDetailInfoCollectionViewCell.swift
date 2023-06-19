//
//  MovieDetailInfoCollectionViewCell.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import UIKit
import Kingfisher

class MovieDetailInfoCollectionViewCell: UICollectionViewCell {
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 16
        view.distribution = .fill
        return view
    }()
    
    private var releaseDateLabel: UILabel!
    private var durationLabel: UILabel!
    private var voteLabel: UILabel!
    private var popularityLabel: UILabel!
    
    func configure(movieDetail: MovieDetailModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let releaseDate = dateFormatter.date(from: movieDetail.releaseDate) {
            let year = Calendar.current.component(.year, from: releaseDate)
            releaseDateLabel.text = "\(year)"
        } else {
            releaseDateLabel.text = "N/A"
        }
        
        let durationInMinutes = movieDetail.duration
            
            let hours = durationInMinutes / 60
            let minutes = durationInMinutes % 60
            
            let durationText: String
            if hours > 0 {
                durationText = "\(hours)h \(minutes)m"
            } else {
                durationText = "\(minutes)m"
            }
            
            durationLabel.text = durationText
        
        if let voteAverage = movieDetail.voteAverage {
            voteLabel.text = "Vote: \(voteAverage)"
        } else {
            voteLabel.text = "Vote: N/A"
        }
        
        if let popularity = movieDetail.popularity {
            popularityLabel.text = "Popularity: \(popularity)"
        } else {
            popularityLabel.text = "Popularity: N/A"
        }
        
        // Additional configuration code for other UI elements
    }


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 48),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        scrollView.addSubview(containerView)
        let traillingAnchor = containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        traillingAnchor.priority = .defaultLow
        let centerXAnchor = containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        centerXAnchor.priority = .defaultLow
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            traillingAnchor,
            centerXAnchor
        ])
        
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
//        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        releaseDateLabel = getLabel()
        durationLabel = getLabel()
        voteLabel = getLabel()
        popularityLabel = getLabel()
        
        stackView.addArrangedSubview(releaseDateLabel)
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(voteLabel)
        stackView.addArrangedSubview(popularityLabel)
    }
    
    private func getLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.gray200
        return label
    }
}
