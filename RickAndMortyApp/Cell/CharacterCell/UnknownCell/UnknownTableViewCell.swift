//
//  UnknownTableViewCell.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 1.04.2023.
//

import UIKit

final class UnknownTableViewCell: UITableViewCell {
    static let identifier = "UnknownTableViewCell"
    
    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        characterImageView.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        characterImageView.image = nil
    }
}
