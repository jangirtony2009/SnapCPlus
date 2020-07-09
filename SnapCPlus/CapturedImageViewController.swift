//
//  CapturedImageViewController.swift
//  SnapCPlus
//
//  Created by vikas.jangir on 08/07/20.
//  Copyright © 2020 vikas.jangir. All rights reserved.
//

import UIKit

class CapturedImageViewController: UIViewController {
    
    @IBOutlet weak var capturedImageView: UIImageView!
    
    var capturedImage: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = capturedImage {
            capturedImageView.image = UIImage(data: image)
        }
    }
    
    @IBAction func dismissButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
