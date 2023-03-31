//
//  CharacterDetailViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 26.03.2023.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var specyLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var epiaodesLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    var selectedCharacter: RMCharacter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        characterImage.layer.cornerRadius = 10
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: "#4FADC8")]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        title = selectedCharacter.name
        fetchData()
    }
    
    private func fetchData() {
        
        guard let imageUrl = URL(string: selectedCharacter.image) else {
            fatalError()
        }
        RMImageLoader.shared.downloadImage(imageUrl) { result in
            switch result {
            case.success(let data):
                DispatchQueue.main.async {
                    self.characterImage.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
        statusLabel.text = selectedCharacter.status.text
        specyLabel.text = selectedCharacter.species
        genderLabel.text = selectedCharacter.gender.rawValue
        originLabel.text = selectedCharacter.origin.name
        locationLabel.text = selectedCharacter.location.name
        epiaodesLabel.text = selectedCharacter.episode.last
        
        let apiDateString = selectedCharacter.created
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: apiDateString)
        
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        let formattedDateString = dateFormatter.string(from: date!)
        createdLabel.text = formattedDateString
    }
}
