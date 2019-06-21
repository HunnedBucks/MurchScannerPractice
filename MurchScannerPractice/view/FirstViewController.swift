//
//  FirsViewController.swift
//  CameraTest
//
//  Created by Hunter Buxton on 6/20/19.
//  Copyright © 2019 Hunter Buxton. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    lazy var scanClothesButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Scan", for: [])
        btn.addTarget(self, action: #selector(scanBtnAction), for: .touchUpInside)
        btn.backgroundColor = .lightGray
        btn.setTitleColor(.lightText, for: [])
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
       // self.navigationController?.pushViewController(ScannerVC(), animated: false)
        present(UINavigationController(rootViewController: ScannerVC()), animated: true)
    }
    
    private func initialUISetup() {
        self.view.backgroundColor = .white
        scanClothesButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scanClothesButton)
        NSLayoutConstraint.activate([
            scanClothesButton.widthAnchor.constraint(equalToConstant: self.view.frame.width/3),
            scanClothesButton.heightAnchor.constraint(equalToConstant: 30.0),
            scanClothesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanClothesButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

    }
    
    @objc func scanBtnAction() {
        print("called scanBtnAction()")
        let nav = UINavigationController(rootViewController: ScannerVC())
        self.present(nav, animated: true)
    }
    
}
