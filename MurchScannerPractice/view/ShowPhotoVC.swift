//
//  ShowPhotoVC.swift
//  MurchScannerPractice
//
//  Created by Hunter Buxton on 6/21/19.
//  Copyright © 2019 Hunter Buxton. All rights reserved.
//

import UIKit

class ShowPhotoVC: UIViewController {
    var photo: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.topAnchor.constraint(equalTo: imageView.topAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
            ])
        imageView.contentMode = .scaleAspectFill
        imageView.image = photo
      //  self.view.backgroundColor = .green
        // Do any additional setup after loading the view.
    }
    

}
