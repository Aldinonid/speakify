//
//  RecordingsViewController.swift
//  Speakify
//
//  Created by Mohammad Sulthan on 28/04/21.
//

import UIKit
import AVFoundation

class RecordingsViewController: UIViewController {
    @IBOutlet weak var recordingTable: UITableView!
	
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!

    var recordingFilePaths:[URL] = []
    var recordingFileNames: [String] = []
    var recordingFiles: [AVAudioPlayer] = []
    var audioPlayer: AVAudioPlayer?
    var audioDurationInt: Int?
    var audioDurationString: String?
    var totalDurationInt: Int?
    let dateComponentsFormatter = DateComponentsFormatter()
    var timer = Timer()
    var recordingFilePlayed: AVAudioPlayer?
    var recordingFileNamePlayed: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTable.dataSource = self
        recordingTable.delegate = self
        getData()
        playButton.isEnabled = false
			
        forwardButton.isEnabled = false
        backwardButton.isEnabled = false

    }
	
	func getData() {
			let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!


		do {
// Get the directory contents urls (including subfolders urls)
				let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
//				print(directoryContents)

// if you want to filter the directory contents you can do like this:
				recordingFilePaths = directoryContents.filter{ $0.pathExtension == "m4a" }
//				print("File urls:",mp3Files)
				recordingFileNames = recordingFilePaths.map{ $0.deletingPathExtension().lastPathComponent }
//				print("File list:", mp3FileNames)
            

		} catch {
				print(error)
		}
	}
    
    @IBAction func backwardClicked(_ sender: Any) {
        guard let audioPlayer = recordingFilePlayed else {
             return
        }
        
        if audioDurationInt! + 10 >= totalDurationInt! {
            audioPlayer.currentTime = 0
            audioDurationInt = Int(audioPlayer.duration)
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            progressView.progress = 0
        } else {
            audioPlayer.currentTime -= 10
            audioDurationInt! += 10
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            progressView.progress = Float(totalDurationInt! - audioDurationInt!)/Float(totalDurationInt!)
        }
    }
    
    @IBAction func playClicked(_ sender: Any) {
        if let audioPlayer = recordingFilePlayed, audioPlayer.isPlaying {
            audioPlayer.pause()
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            guard let audioPlayer = recordingFilePlayed else {
                 return
            }
            audioPlayer.play()
            if audioPlayer.currentTime == 0 {
                audioDurationInt = Int(audioPlayer.duration)
                dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
                dateComponentsFormatter.unitsStyle = .positional
                audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
                durationLabel.text = "-\(audioDurationString!)"
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reduceTime), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @IBAction func forwardClicked(_ sender: Any) {
        guard let audioPlayer = recordingFilePlayed else {
             return
        }
        
        if audioDurationInt! - 10 <= 0 {
            audioPlayer.stop()
            timer.invalidate()
            audioDurationInt = Int(audioPlayer.duration)
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            progressView.progress = 0
        } else {
            audioPlayer.currentTime += 10
            audioDurationInt! -= 10
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            progressView.progress = Float(totalDurationInt! - audioDurationInt!)/Float(totalDurationInt!)
        }
    }
    
    @objc func reduceTime() {
        if audioDurationInt! - 1 < 0 {
            timer.invalidate()
            guard let audioPlayer = recordingFilePlayed else {
                 return
            }
            audioPlayer.stop()
            audioDurationInt = Int(audioPlayer.duration)
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            progressView.progress = 0
        } else {
            audioDurationInt! -= 1
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(audioDurationInt!))
            durationLabel.text = "-\(audioDurationString!)"
            progressView.progress = Float(totalDurationInt! - audioDurationInt!)/Float(totalDurationInt!)
        }
    }
}


extension RecordingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let audioPlayer = recordingFilePlayed {
            audioPlayer.stop()
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            progressView.progress = 0
        }
        titleLabel.text = recordingFileNames[indexPath.row]
        
        totalDurationInt = Int(recordingFiles[indexPath.row].duration)
        dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
        dateComponentsFormatter.unitsStyle = .positional
        dateComponentsFormatter.zeroFormattingBehavior = .pad
        audioDurationString = dateComponentsFormatter.string(from: TimeInterval(totalDurationInt!))
        durationLabel.text = "-\(audioDurationString!)"
        
        recordingFilePlayed = recordingFiles[indexPath.row]
        recordingFileNamePlayed = recordingFileNames[indexPath.row]
        
        audioDurationInt = Int(recordingFilePlayed!.duration)
        
        playButton.isEnabled = true
        backwardButton.isEnabled = true
        forwardButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
				return recordingFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        getData()
        let cell = recordingTable.dequeueReusableCell(withIdentifier: "recordingViewCell") as! RecordingTableViewCell
        let title = recordingFileNames[indexPath.row]
        
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioPlayer = try AVAudioPlayer(contentsOf: recordingFilePaths[indexPath.row])
            recordingFiles.append(audioPlayer!)
            
            totalDurationInt = Int(audioPlayer!.duration)
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.unitsStyle = .positional
            dateComponentsFormatter.zeroFormattingBehavior = .pad
            audioDurationString = dateComponentsFormatter.string(from: TimeInterval(totalDurationInt!))
            
        }
        catch {
            print("Something Went Wrong...")
        }
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = audioDurationString
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = self.recordingFileNames[indexPath.row]
        let titles = self.recordingFileNames

        
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            //Code after delete button pressed
            let alert = UIAlertController(title: "Delete Recording", message: "Are you sure you want to delete \(title)?", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { [self]
                action in
                try? FileManager.default.removeItem(at: self.recordingFilePaths[indexPath.row])
                if self.recordingFileNamePlayed == self.recordingFileNames[indexPath.row] {
                    self.titleLabel.text = "No Label"
                    self.durationLabel.text = "Duration"
                    
                    self.playButton.isEnabled = false
                    self.backwardButton.isEnabled = false
                    self.forwardButton.isEnabled = false
                }
                self.recordingFilePaths.remove(at: indexPath.row)
                self.recordingFileNames.remove(at: indexPath.row)
                self.recordingFiles.removeAll()
                tableView.reloadData()
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            //Code after edit button pressed
            
            let alert = UIAlertController(title: "Edit Title", message: "Put your new title for \(title) here", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let edit = UIAlertAction(title: "Edit", style: .default, handler: {
                action in
                
                var newName = "\(alert.textFields![0].text ?? "default").m4a"
                var newNameNoExtension = "\(alert.textFields![0].text ?? "default")"
                var isDuplicate = false
                
                if titles.contains(newNameNoExtension){
                    var number = 0
                    isDuplicate = true
                    
                    while isDuplicate{
                        number += 1
                        newName = "\(alert.textFields![0].text ?? "default")(\(number))"
                        
                        if !titles.contains(newName){
                            isDuplicate = false
                            newNameNoExtension = newName
                            newName = "\(newName).m4a"
                        }
                    }
                }
                

                if self.playButton.isEnabled {
                    self.titleLabel.text = newNameNoExtension
                }
                let newURL = self.recordingFilePaths[indexPath.row].deletingLastPathComponent().appendingPathComponent(newName)
                try? FileManager.default.moveItem(at: self.recordingFilePaths[indexPath.row], to: newURL)
                
                self.recordingFiles.removeAll()
                tableView.reloadData()
            })
            
            alert.addTextField { (textField:UITextField) in
                textField.placeholder = "New title"
                textField.keyboardType = .default
            }
            
            alert.addAction(edit)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
        
    }
    
}
