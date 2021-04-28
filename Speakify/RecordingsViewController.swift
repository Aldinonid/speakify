//
//  RecordingsViewController.swift
//  Speakify
//
//  Created by Mohammad Sulthan on 28/04/21.
//

import UIKit

class RecordingsViewController: UIViewController {
    
    @IBOutlet weak var recordingTable: UITableView!
    @IBOutlet weak var timerRow: UILabel!
    let categories = ["Recording 1", "Recording 2"]

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTable.dataSource = self
        recordingTable.delegate = self
    }
}

extension RecordingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordingTable.dequeueReusableCell(withIdentifier: "recordingViewCell") as! RecordingTableViewCell
        
        let title = categories[indexPath.row]
        
        cell.labelTitle?.text = title
        cell.detailTextLabel?.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = self.categories[indexPath.row]

        
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            //Code after delete button pressed
            let alert = UIAlertController(title: "Delete Recording", message: "Are you sure you want to delete \(title)?", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: nil)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            //Code after edit button pressed
            
            let alert = UIAlertController(title: "Edit Title", message: "Put your new title for \(title) here", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: nil)
            
            alert.addTextField { (textField:UITextField) in
                textField.placeholder = "New title"
                textField.keyboardType = .default
            }
            
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
    }
}
