//
//  CharacterDetailViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 26.03.2023.
//

import UIKit
import Kingfisher

final class CharacterDetailViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var replyStackView: UIStackView!
    @IBOutlet weak var titleStackView: UIStackView!
    
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var specyLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var epiaodesLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    var selectedCharacter: RMCharacter!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        characterImage.layer.cornerRadius = 10
        fetchData()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    //MARK: - Private Func
    
    private func setUpNavigationBar() {
        self.navigationItem.title = selectedCharacter.name
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hex: "#4FADC8"), .font: UIFont(name: "Avenir Medium", size: 22)!]
    }
    
    private func fetchData() {
        
        characterImage.kf.setImage(with: selectedCharacter.image.asUrl)
        statusLabel.text = selectedCharacter.status.text
        specyLabel.text = selectedCharacter.species
        genderLabel.text = selectedCharacter.gender.rawValue
        originLabel.text = selectedCharacter.origin.name
        locationLabel.text = selectedCharacter.location.name
        
        let episodesNumbers = selectedCharacter.episode.map {
            $0.split(separator: "/").last
        }.compactMap { $0 }.joined(separator: ",")
        
        DispatchQueue.main.async {
            self.epiaodesLabel.text = episodesNumbers
        }
        
        let apiDateString = selectedCharacter.created
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: apiDateString)
        
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        let formattedDateString = dateFormatter.string(from: date!)
        createdLabel.text = formattedDateString
    }
}
