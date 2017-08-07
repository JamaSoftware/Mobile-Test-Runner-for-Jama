//
//  TestRunIndexViewController.swift
//  Mobile Test Runner for Jama
//
//  Created by Meghan McBee on 7/27/17.
//  Copyright © 2017 Jaca. All rights reserved.
//

import UIKit

protocol StepIndexDelegate {
    func didSetStatus(status: Status)
    func didSetResult(result: String)
}

enum Status {
    case pass, fail, not_run
}

class TestRunIndexViewController: UIViewController, UITextViewDelegate {
   
    @IBOutlet weak var cancelRun: UIBarButtonItem!
    @IBOutlet weak var testRunNameLabel: UILabel!
    @IBOutlet weak var testStepTable: UITableView!
    @IBOutlet weak var inputResultsButton: UIButton!
    @IBOutlet weak var inputResultsBox: UIView!
    @IBOutlet weak var inputResultsTextBox: UITextView!
    @IBOutlet weak var inputResultsBackground: UIView!
    @IBOutlet weak var noStepsView: UIView!
    @IBOutlet weak var noStepStatusIcon: UIImageView!
    
    var instance = ""
    var username = ""
    var password = ""
    var runId = -1
    var runName = ""
    var currentlySelectedStepIndex = -1
    var testRun: TestRunModel = TestRunModel()
    var initialStepsStatusList: [String] = []
    var initialStepsResultsList: [String] = []
    var initialRunResultField = ""
    let placeholderText = "Enter run results here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the default back button and instead show cancel run
        self.navigationItem.hidesBackButton = true
        testRunNameLabel.text = testRun.name
        self.setupPopup()
        testStepTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        testStepTable.reloadData()
        //If there are no steps, display the no steps view
        if testRun.testStepList.isEmpty {
            noStepsView.isHidden = false
        } else {
            noStepsView.isHidden = true
        }
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
            var index = 0
            //Run cancelled, reset all of the results and statuses to initial values
            for step in self.testRun.testStepList {
                step.status = self.initialStepsStatusList[index]
                step.result = self.initialStepsResultsList[index]
                index += 1
            }
            self.testRun.result = self.initialRunResultField
            self.navigationController?.popViewController(animated: true)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Never mind", style: .cancel, handler: {
            (action: UIAlertAction!) in
            _ = ""
            
        }))
        
        present(cancelAlert, animated: true, completion: nil)
    }
    
    //Save all of the inital values of the statuses
    func preserveCurrentRunStatus() {
        for step in testRun.testStepList {
            let status = step.status
            let results = step.result
            initialStepsStatusList.append(status)
            initialStepsResultsList.append(results)
        }
        initialRunResultField = testRun.result
    }
    
    // Used to set up text window popup, called in viewDidLoad
    func setupPopup() {
        NotificationCenter.default.addObserver(self, selector: #selector(TestRunIndexViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TestRunIndexViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        inputResultsBox.isHidden = true
        inputResultsBackground.isHidden = true
        inputResultsTextBox.delegate = self
        setPlaceholderText()
    }
    
    func setPlaceholderText() {
        if testRun.result == "" {
            inputResultsTextBox.text = placeholderText
            inputResultsTextBox.textColor = UIColor(red: 0.5882, green: 0.5882, blue: 0.5882, alpha: 1.0) /* #969696 */
        } else {
            inputResultsTextBox.text = testRun.result
        }
    }
    
    // Called when 'Input Results' button is clicked
    @IBAction func enterText(_ sender: UIButton) {
        inputResultsBackground.isHidden = false
        inputResultsBox.isHidden = false
    }
    
    // Called when 'Done' button in popup is clicked
    @IBAction func saveText(_ sender: UIButton) {
        inputResultsBackground.isHidden = true
        inputResultsBox.isHidden = true
        if testRun.result != inputResultsTextBox.text && inputResultsTextBox.text != placeholderText {
            testRun.result = inputResultsTextBox.text
        }
        inputResultsTextBox.resignFirstResponder()
    }
    
    // Move popup when keyboard appears/hides
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.inputResultsBox.frame.origin.y -= keyboardSize.height/3
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.inputResultsBox.frame.origin.y += keyboardSize.height/3
        }
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        inputResultsTextBox.resignFirstResponder()
        return (true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if inputResultsTextBox.text == placeholderText {
            inputResultsTextBox.text = ""
            inputResultsTextBox.textColor = UIColor.black
        }
    }
    @IBAction func didTapPassRun(_ sender: Any) {
        noStepStatusIcon.image = UIImage(named: "check_icon_green.png")
    }
    
    @IBAction func didTapFailRun(_ sender: Any) {
        noStepStatusIcon.image = UIImage(named: "X_icon_red.png")
    }

    
    //TODO make the link between the button and the setting of the status for the run
    //TODO make confirmation popup that this will submit the test run
    //TODO make
    
    //make the put request with the test run data
    func submitTestRun() {
        let putEndpoint = buildTestRunEndpointString()
        RestHelper.hitEndpoint(atEndpointString: putEndpoint, withDelegate: self, httpMethod: "Put", username: username, password: password)
    }
    
    //build the endpoint for submitting the test run
    func buildTestRunEndpointString() -> String {
        var endpoint = RestHelper.getEndpointString(method: "Put", endpoint: "TestRuns")
        endpoint = "https://" + instance + "." + endpoint
        return endpoint.replacingOccurrences(of: "{id}", with: "\(runId)")
    }
    
    //build the JSON body of the put request
    func JSONStringify() -> String{
        var stringJSON = ""
        var index = 0
        
        // build the "testRunSteps"
        var testRunString = "\"testRunSteps\": ["
        for step in testRun.testStepList {
            testRunString += "{" + "\"action\": " + "\"" + step.action + "\"" + ","
            testRunString += "\"expectedResult\": " + "\"" + step.expectedResult + "\"" + ","
            testRunString += "\"notes\": " + "\"" + step.notes + "\"" + ","
            testRunString += "\"result\": " + "\"" + step.result + "\"" + ","
            testRunString += "\"status\" :" + "\"" + step.status + "\"" + "}"
            if index != testRun.testStepList.endIndex - 1 {
                testRunString += ","
            }
            index += 1
        }
        testRunString += "]"
        
        // build the "actualResults"
        var actualResultsString = "\"actualResults\": "
        actualResultsString += "\"" + self.testRun.result + "\""

        // build the "testRunStatus"
        var testRunStatusString = "\"testRunStatus\": "
        testRunStatusString += "\"" + self.testRun.testStatus + "\""
        
        //build the whole JSON body
        stringJSON += "{" + "\"fields\" : {" + testRunString + "," + actualResultsString + "," + testRunStatusString + "}}"
        return stringJSON
    }
  /*  func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(value) {
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                print("error")
            }
        }
        return ""
    }
    */
}

//TODO implement this extension
extension TestRunIndexViewController: EndpointDelegate{
    func didLoadEndpoint(data: [[String: AnyObject]]?, totalItems: Int) {
        //if it returns 200, show confirmation that results submitted
        //if it returns anything other than 200, show error message
    }
}


extension TestRunIndexViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testRun.testStepList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = TestStepTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TestStepCell")
        cell.customInit(tableWidth: tableView.bounds.width, stepNumber: indexPath.row + 1, stepName: testRun.testStepList[indexPath.row].action, stepStatus: testRun.testStepList[indexPath.row].status)

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stepDetailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Test Step") as! TestStepViewController
        
        stepDetailController.action = testRun.testStepList[indexPath.row].action
        stepDetailController.expResult = testRun.testStepList[indexPath.row].expectedResult
        stepDetailController.notes = testRun.testStepList[indexPath.row].notes
        stepDetailController.stepResult = testRun.testStepList[indexPath.row].result
        
        stepDetailController.currentIndex = indexPath.row
        stepDetailController.indexLength = testRun.testStepList.count
        
        currentlySelectedStepIndex = indexPath.row
        stepDetailController.indexDelegate = self
        self.navigationController?.pushViewController(stepDetailController, animated: true)
    }
}

extension TestRunIndexViewController: StepIndexDelegate {
    func didSetStatus(status: Status) {
        var result = ""
        switch status {
        case .fail:
            result = "FAILED"
        case .pass:
            result = "PASSED"
        case .not_run:
            result = "NOT_RUN"
        }
        testRun.testStepList[currentlySelectedStepIndex].status = result
    }
    
    func didSetResult(result: String) {
        testRun.testStepList[currentlySelectedStepIndex].result = result
    }
}
