//
//  MoviePosterCollectionViewCell.swift
//  Movies Explorer
//
//  Created by MacBook on 10.06.2023.
//

import UIKit
import Kingfisher

class MoviePosterCollectionViewCell: UICollectionViewCell {
    private let posterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func configure(movie: MoviePosterModel) {
        guard let url = URL(string: movie.posterPath) else { return }
        posterImage.kf.setImage(with: url)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.addSubview(posterImage)
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    } 
}
