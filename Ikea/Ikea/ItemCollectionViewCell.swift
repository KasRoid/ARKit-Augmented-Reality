//
//  ItemCollectionViewCell.swift
//  Ikea
//
//  Created by Kas Song on 12/8/20.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ItemCollectionViewCell"
    
    let label = UILabel()
    override var isSelected: Bool {
        didSet {
            isSelected ? { self.backgroundColor = .green }() : { self.backgroundColor = .orange }()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ItemCollectionViewCell {
    private func setupUI() {
        self.backgroundColor = .systemOrange
        label.textColor = .black
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
