//
//  ViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 24.03.2023.
//

import UIKit
import Kingfisher

final class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "titleImage")
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return imageView
    }()
    
    var locations: [RMLocation] = []
    var characters: [RMCharacter] = []
    var filterCharacters: [RMCharacter] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = imageView
        fetchLocation()
        registerCell()
    }
    
    //MARK: - Private Funcs
    private func registerCell() {
        tableView.register(UINib(nibName: String(describing: MaleTableViewCell.self), bundle: nil), forCellReuseIdentifier: MaleTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: FemaleTableViewCell.self), bundle: nil), forCellReuseIdentifier: FemaleTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: UnknownTableViewCell.self), bundle: nil), forCellReuseIdentifier: UnknownTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: GenderlessTableViewCell.self), bundle: nil), forCellReuseIdentifier: GenderlessTableViewCell.identifier)
    }
    
    private func fetchLocation() { RMService.shared.execute(
        .listLocationsRequest,
        expecting: RMGetAllLocationsResponse.self
    ) { [weak self] result in
        switch result {
        case .success(let responseModel):
            let results = responseModel.results
            self?.locations = results
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        case .failure(let error):
            print(String(describing: error))
        }
    }
    }
    
    private func fetchRelatedCharacters(location: RMLocation, completion: @escaping ([RMCharacter]) -> Void) {
        let requests: [RMRequest] = location.residents.compactMap({
            return URL(string: $0)
        }).compactMap({
            return RMRequest(url: $0)
        })
        
        let group = DispatchGroup()
        var characterss: [RMCharacter] = []
        for request in requests {
            group.enter()
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let model):
                    characterss.append(model)
                case .failure:
                    break
                }
            }
        }
        group.notify(queue: .main) {
            completion(characterss)
        }
    }
}

//MARK: -  UICollecitonView Fetch location name
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCollectionViewCell.cellIdentifier, for: indexPath) as? LocationCollectionViewCell else {
            fatalError("Cell not found")
        }
        let location = locations[indexPath.item]
        cell.nameLabel.text = location.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let location = locations[indexPath.item]
        
        if location.residents.count == 0 {
            self.showAlert(alertText: "Nothing Found", alertMessage: "The residents of the locations you selected were not found")
        }
        
        fetchRelatedCharacters(location: location) { [weak self] characters in
            self?.filterCharacters = characters
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableView Fetch characters and show detail
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCharacters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let character = filterCharacters[indexPath.row]
        
        if character.gender == .male {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MaleTableViewCell.identifier, for: indexPath) as? MaleTableViewCell else {
                fatalError("Unable to dequeue MaleTableViewCell")
            }
            cell.nameLabel.text = character.name
            cell.characterImageView.kf.setImage(with: character.image.asUrl)
            return cell
            
        } else if character.gender == .female {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FemaleTableViewCell.identifier, for: indexPath) as? FemaleTableViewCell else {
                fatalError("Unable to dequeue FemaleTableViewCell")
            }
            cell.characterName.text = character.name
            cell.characterImage.kf.setImage(with: character.image.asUrl)
            return cell
            
        } else if character.gender == .unknown {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UnknownTableViewCell.identifier, for: indexPath) as? UnknownTableViewCell else {
                fatalError("Unable to dequeue UnknownTableViewCell")
            }
            cell.nameLabel.text = character.name
            cell.characterImageView.kf.setImage(with: character.image.asUrl)
            return cell
        }
        else if character.gender == .genderless {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GenderlessTableViewCell.identifier, for: indexPath) as? GenderlessTableViewCell else {
                fatalError("Unable to dequeue GenderlessTableViewCell")
            }
            cell.nameLabel.text = character.name
            cell.characterImage.kf.setImage(with: character.image.asUrl)
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if storyboard?.instantiateViewController(withIdentifier: "detailVC") is CharacterDetailViewController {
            self.performSegue(withIdentifier: "detailVC", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailVC" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let character = filterCharacters[indexPath.row]
                let destinationVC = segue.destination as! CharacterDetailViewController
                destinationVC.selectedCharacter = character
            }
        }
    }
}


