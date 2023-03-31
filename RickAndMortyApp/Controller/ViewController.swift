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
    
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
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
                let info = responseModel.info
                self?.characters = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    private var isLoadingMoreCharacters = false
    
    // Aşşağı kaydırdıkça tüm karakterler geliyor ama colleciton view cell deki name bastığımda  eşleşenlerin filtrelenip öyle gelmesi lazım
    
    public func fetchAdditionalCharacters(url: URL) {
        guard !isLoadingMoreCharacters else {
            return
        }
        
        isLoadingMoreCharacters = true
       guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            return
        }
        
       RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
           guard let strongSelf = self else {
               return
           }
           switch result {
           case .success(let responseModel):
               let moreResults = responseModel.results
               let info = responseModel.info
               strongSelf.apiInfo = info
               
               let originalCount = strongSelf.characters.count
               let newCount = moreResults.count
               let total = originalCount+newCount
               let startingIndex = total - newCount
               let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                   return IndexPath(row: $0, section: 0)
               })
            
               strongSelf.characters.append(contentsOf: moreResults)
               DispatchQueue.main.async {
                   self?.tableView.reloadData()
                   strongSelf.isLoadingMoreCharacters = false
                  }
               
           case .failure(let failure):
               print(String(describing: failure))
               self?.isLoadingMoreCharacters = false
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
        
        // eşleşenler ile locaiton name characterler liste güncellenmeli
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

//MARK: - ScrollViewDelegate Control
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoadingMoreCharacters,
        let nextUrlString = apiInfo?.next,
        let url = URL(string: nextUrlString) else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeigh = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
          
            if offset >= (totalContentHeigh - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalCharacters(url: url)
            }
            t.invalidate()
        }
    }
}
