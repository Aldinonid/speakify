//
//  ViewController.swift
//  Speakify
//
//  Created by Aldino Efendi on 27/04/3 R.
//

import UIKit

class ViewController: UIViewController {
			
	@IBOutlet weak var image1: UIImageView!
	@IBOutlet weak var image2: UIImageView!

	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	
	
	override func viewDidLoad() {
	super.viewDidLoad()
			button1.layer.cornerRadius = 15
			button2.layer.cornerRadius = 15
			image1.layer.cornerRadius = 15
			image2.layer.cornerRadius = 15
			image1.layer.borderColor = UIColor.gray.cgColor
			image1.layer.borderWidth = 1
			image2.layer.borderColor = UIColor.gray.cgColor
			image2.layer.borderWidth = 1
	}

	@IBAction func button1Tapped(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(identifier: "TrainingScreen") as! TrainingViewController
		
		vc.isQuestionable = true
		vc.isInterviewImage = true
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
	@IBAction func button2Tapped(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(identifier: "TrainingScreen") as! TrainingViewController
		
		vc.isQuestionable = false
		vc.isInterviewImage = false
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
}

