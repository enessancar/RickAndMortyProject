//
//  LocationCollectionViewCell.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 25.03.2023.
//

import UIKit

final class LocationCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "locationCell"
    
    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .systemBlue : .systemGray5
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
