//
//  LocationCollectionViewCell.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 25.03.2023.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .systemBlue : .systemGray6
        }
    }
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 0.75
        contentView.layer.borderColor = UIColor.darkText.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }
}
