//
//  GenderlessTableViewCell.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 2.04.2023.
//

import UIKit

final class GenderlessTableViewCell: UITableViewCell {
    static let identifier = "GenderlessTableViewCell"
    
    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        characterImage.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        characterImage.image = nil
    }
}
