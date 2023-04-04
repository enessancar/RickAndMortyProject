//
//  FemaleTableViewCell.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 1.04.2023.
//

import UIKit

final class FemaleTableViewCell: UITableViewCell {
    static let identifier = "FemaleTableViewCell"

    //MARK: - Properties
    @IBOutlet weak var characterName: UILabel!
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
        characterImage.image = nil
        characterName.text = nil
    }
}
