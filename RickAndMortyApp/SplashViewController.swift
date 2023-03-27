//
//  SplashViewController.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 27.03.2023.
//

import UIKit

class SplashViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                imageView.image = UIImage(named: "welcome")
                UserDefaults.standard.set(false, forKey: "isFirstLaunch")
            } else {
                imageView.image = UIImage(named: "hello")
            }
    }
}
