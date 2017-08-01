//
//  TestRunIndexViewController.swift
//  Mobile Test Runner for Jama
//
//  Created by Meghan McBee on 7/27/17.
//  Copyright © 2017 Jaca. All rights reserved.
//

import UIKit

class TestRunIndexViewController: UIViewController {
   
    @IBOutlet weak var cancelRun: UIBarButtonItem!
    @IBOutlet weak var testRunNameLabel: UILabel!
    @IBOutlet weak var testStepTable: UITableView!
    @IBOutlet weak var inputResultsButton: UIButton!
    @IBOutlet weak var inputResultBox: UIView!
    
    var instance = ""
    var username = ""
    var password = ""
    var runId = -1
    var runName = ""
    var testRun: TestRunModel = TestRunModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the default back button and instead show cancel run
        self.navigationItem.hidesBackButton = true
        testRunNameLabel.text = runName
        testStepTable.reloadData()
        inputResultBox.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRun(_ sender: UIBarButtonItem) {
        //if the cancel run button is hit, pop up an alert that either does nothing or goes back a screen to select a different run.
        let cancelAlert = UIAlertController(title: "Cancel Run", message: "All run data will be lost. Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: {
            (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Never mind", style: .cancel, handler: {
            (action: UIAlertAction!) in
            _ = ""
            
        }))
        
        present(cancelAlert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func enterText(_ sender: UIButton) {
        inputResultBox.isHidden = false
        /*
        let inputTextAlert = UIAlertController(title: nil, message: "Enter Results", preferredStyle: UIAlertControllerStyle.alert)
        
        inputTextAlert.addTextField { (textField) in
            textField.clearsOnBeginEditing = false
            var frameRect = textField.frame
            frameRect.size.height = 125
            textField.frame = frameRect
        }
        
        let confirmAction = UIAlertAction(title: "Done", style: .default) { (_) in
            self.testRun.result = (inputTextAlert.textFields?[0].text)!
            print(self.testRun.result)
        }
        
        inputTextAlert.addAction(confirmAction)
        present(inputTextAlert, animated: true, completion: nil)
 */
    }

}

extension TestRunIndexViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO this is hard coded until we implement loading real steps into the screen.
        return 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = TestStepTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TestStepCell")
        cell.customInit(tableWidth: tableView.bounds.width, stepNumber: indexPath.row + 1, stepName: runName)

        return cell
    }
}
