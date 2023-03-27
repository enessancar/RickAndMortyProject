//
//  ViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 24.03.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "titleImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var locations: [RMLocation] = []
    var characters: [RMCharacter] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = imageView
        fetchLocation()
        fetchCharacters()
    }
    
    public func fetchLocation() { RMService.shared.execute(
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
    
    public func fetchCharacters() {
        RMService.shared.execute(
            .listCharacterRequests,
            expecting: RMGetAllCharactersResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let results = responseModel.results
                self?.characters = results
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    // Deneme amaçlı  locaiton name basınca aşağıda o location daki karakterleri listelemek için
    private func fetchRelatedCharacters(location: RMLocation) {
        let requests: [RMRequest] = location.residents.compactMap({
            return URL(string: $0)
        }).compactMap({
            return RMRequest(url: $0)
        })
        
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        for request in requests {
            group.enter()
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }
    }
}

//MARK: -  UICollecitonView Fetch location name
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as? LocationCollectionViewCell else {
            fatalError("Cell not found")
        }
        let location = locations[indexPath.item]
        cell.nameLabel.text = location.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let location = locations[indexPath.item]
        let character = characters[indexPath.row]
        
        if location.id == character.id {
            print("eşleşti")
            DispatchQueue.main.async {
                self.fetchRelatedCharacters(location: location)
                self.fetchCharacters()
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableView Fetch characters and show detail
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as? CharacterTableViewCell else {
            fatalError("Unable to dequeue CharacterCell")
        }
        
        let character = characters[indexPath.row]
        cell.nameLabel.text = character.name
        cell.statusLabel.text = character.status.text
        
        guard let imageUrl = URL(string: character.image) else {
            fatalError()
        }
        RMImageLoader.shared.downloadImage(imageUrl) { result in
            switch result {
            case.success(let data):
                DispatchQueue.main.async {
                    cell.characterImageView.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if storyboard?.instantiateViewController(withIdentifier: "detailVC") is CharacterDetailViewController {
            self.performSegue(withIdentifier: "detailVC", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailVC" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let character = characters[indexPath.row]
                let destinationVC = segue.destination as! CharacterDetailViewController
                destinationVC.selectedCharacter = character
            }
        }
    }
}
