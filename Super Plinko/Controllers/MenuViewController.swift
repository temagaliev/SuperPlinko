//
//  MenuViewController.swift
//  Super Plinko
//
//  Created by Artem Galiev on 20.09.2023.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playAction(_ sender: Any) {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func privacyPolicyAction(_ sender: Any) {
        let vc = PrivacyPolicyViewController()
        present(vc, animated: true)

    }
    
}
