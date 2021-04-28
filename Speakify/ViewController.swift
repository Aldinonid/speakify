//
//  ViewController.swift
//  Speakify
//
//  Created by Aldino Efendi on 27/04/3 R.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
  
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    
    override func viewDidLoad() {
		super.viewDidLoad()
        button1.layer.cornerRadius = 15
        self.view.bringSubviewToFront(button1)
        button2.layer.cornerRadius = 15
        self.view.bringSubviewToFront(button2)
        image1.layer.cornerRadius = 15
        image2.layer.cornerRadius = 15
        
        image1.contentMode = .scaleAspectFill
        image2.contentMode = .scaleAspectFill
}
}
