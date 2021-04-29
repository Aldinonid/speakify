//
//  TrainingViewController.swift
//  Speakify
//
//  Created by Aldino Efendi on 28/04/3 R.
//

import UIKit
import AVFoundation

class TrainingViewController: UIViewController, AVAudioRecorderDelegate {

	@IBOutlet weak var trainingImage: UIImageView!
	@IBOutlet weak var recordImage: UIImageView!
	@IBOutlet weak var timerLabel: UILabel!
	
	var recordingSession: AVAudioSession!
	var audioRecorder: AVAudioRecorder!
	var isQuestionable: Bool = false
	var numberOfRecords: Int = 0
	var timer: Timer = Timer()
	var count: Double = 0.0
	var opQueue = OperationQueue()
	
	var question: [String] = [	"Tell me about yourself.",
														"What are your strength?",
														"What are your weaknesses?",
														"Why are you leaving / left your previous job?",
														"Why should we hire you?",
														"Where do you see yourself in 5 years?",
														"Why do you want this job?",
														"Do you consider yourself successful?",
														"What motivates you to join this company?",
														"What skills do you bring to the program?",
														"How does our program fit with your goals?"
													]
	
	var isInterviewImage: Bool = false
	
	override func viewDidLoad() {
			super.viewDidLoad()
		
			if (isQuestionable) {
				let alert = UIAlertController(title: "Question", message: question.randomElement(), preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Begin", style: .default, handler: nil))
				self.opQueue.addOperation {
					OperationQueue.main.addOperation({
						self.present(alert, animated: true, completion: nil)
					})
				}
				isQuestionable = false
			}
		
			if (isInterviewImage) {
				trainingImage.image = UIImage(named: "ibuInterviewerRecord2")
			} else {
				trainingImage.image = UIImage(named: "speechRecord")
			}

			let tapImage = UITapGestureRecognizer(target: self, action: #selector(onClick))
			recordImage.addGestureRecognizer(tapImage)
			recordImage.isUserInteractionEnabled = true
// Set up session
			recordingSession = AVAudioSession.sharedInstance()
		
		if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
			numberOfRecords = number
		}
		
			AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
				if hasPermission {
					print("ACCEPTED")
				}
			}
	}
    

	@objc func onClick() {
		if audioRecorder == nil {
			numberOfRecords += 1
			let filename = getDirectory().appendingPathComponent("Recording \(numberOfRecords).m4a")
			let settings = [
							AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
							AVSampleRateKey: 12000,
							AVNumberOfChannelsKey: 1,
							AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
					]
			
			do {
// Start recording
				audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
				audioRecorder.delegate = self
				audioRecorder.record()
				
// Locate recording file
				print("Recording file is : \(filename)")
				
				timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
				
				UIView.animate(withDuration: 0.5) {
					self.recordImage.alpha = 0
					self.recordImage.image = UIImage(named: "StopRecordButton")
					self.recordImage.alpha = 1
				}
			} catch {
					let alert = UIAlertController(title: "Oops!", message: "Recording failed", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
					present(alert, animated: true, completion: nil)
			}
		} else {
// Stop recording
				let filename = getDirectory().appendingPathComponent("Recording \(numberOfRecords).m4a")
				audioRecorder.stop()
				audioRecorder = nil
				timer.invalidate()

				UIView.animate(withDuration: 0.5) {
					self.recordImage.alpha = 0
					self.recordImage.image = UIImage(named: "StartRecordButton")
					self.recordImage.alpha = 1
				}
			
				let alert = UIAlertController(title: "Recording Finished", message: "Do you want to save your recording?", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
					self.numberOfRecords -= 1
					UserDefaults.standard.set(self.numberOfRecords, forKey: "myNumber")
					self.removeRecording(fileName: filename)
					self.timerLabel.text = "\(self.makeTimeString(hours: 0, minutes: 0, seconds: 0)).0"

				}))
				alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
					UserDefaults.standard.set(self.numberOfRecords, forKey: "myNumber")
					print("Recording Saved")
					self.timerLabel.text = "\(self.makeTimeString(hours: 0, minutes: 0, seconds: 0)).0"
				}))
				present(alert, animated: true, completion: nil)
				self.count = 0.0
		}
	}
	
	@objc func timerCounter() -> Void {
		count = count + 0.1
		let flooredCounter = Int(floor(count))
		let time = secondsToHoursMinutesSecondsDeciseconds(seconds: flooredCounter)
		let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
		let deciSecond = String(format: "%.1f", count).components(separatedBy: ".").last!
		timerLabel.text = "\(timeString).\(deciSecond)"
	}
	
	func secondsToHoursMinutesSecondsDeciseconds(seconds: Int) -> (Int, Int, Int) {
		return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
	}
	
	func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
		var timeString = ""
		timeString += String(format: "%02d", hours)
		timeString += " : "
		timeString += String(format: "%02d", minutes)
		timeString += " : "
		timeString += String(format: "%02d", seconds)
		return timeString
	}
	
// Get path to directory
	func getDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentDirectory = paths[0]
		return documentDirectory
	}
	
	func removeRecording(fileName: URL) {
		do {
			let fileManager = FileManager.default
// Check if file exists
			if fileManager.fileExists(atPath: fileName.path) {
// If exits, system will delete the file
				try fileManager.removeItem(atPath: fileName.path)
			} else {
					print("File does not exist")
				}
		}
		catch let error as NSError {
			print("An error took place: \(error)")
		}
	}

}
