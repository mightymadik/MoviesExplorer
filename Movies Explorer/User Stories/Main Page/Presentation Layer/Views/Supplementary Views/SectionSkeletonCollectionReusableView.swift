//
//  SectionSkeletonCollectionReusableView.swift
//  Movies Explorer
//
//  Created by MacBook on 13.06.2023.
//

import UIKit

class SectionSkeletonCollectionReusableView: UICollectionReusableView {
    weak var delegate: SectionHeaderCollectionReusableViewDelegate?
    
    private let titleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.gray150
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let buttonView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.gray150
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleView.topAnchor.constraint(equalTo: topAnchor),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleView.widthAnchor.constraint(equalToConstant: 100),
            titleView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        addSubview(buttonView)
        NSLayoutConstraint.activate([
            buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            buttonView.widthAnchor.constraint(equalToConstant: 66),
            buttonView.heightAnchor.constraint(equalToConstant: 24 )
             
        ])
    }
    
}
