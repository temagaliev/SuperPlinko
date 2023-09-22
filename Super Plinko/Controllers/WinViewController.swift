//
//  WinViewController.swift
//  Super Plinko
//
//  Created by Artem Galiev on 20.09.2023.
//

import UIKit

class WinViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func nextAction(_ sender: Any) {
        GameViewController.gameLevel = GameViewController.gameLevel + 1
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
