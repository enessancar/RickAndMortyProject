//
//  SplashViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 27.03.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.performSegue(withIdentifier: "mainVC", sender: nil)
        }
    }
    
    private func setupUI() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            imageView.image = UIImage(named: "hello")
        } else {
            imageView.image = UIImage(named: "welcome")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
}
