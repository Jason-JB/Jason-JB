//
//  ContentView.swift
//  Lab8
//
//  Created by Bendickson, Jason J on 12/1/19.
//  Copyright © 2019 Bendickson, Jason J. All rights reserved.
//

import UIKit
import SQLite3

let bgColor: UIColor = UIColor()

class MainScreen: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let ActivityCell: String = "ActivityCell"
    
    let dirPath: String = "\(NSHomeDirectory())/tmp"
    let filePath: String = "\(NSHomeDirectory())/tmp/activity.txt"

    var db: OpaquePointer?
    
    let activityTableView: UITableView = UITableView()
    var activityList = [Activity]()
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = SettingsViewController.sharedInstance.backgroundColor

      
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
    
    var button = UIButton(type: UIButton.ButtonType.custom)
    button.frame = CGRect(x: view.center.x-100, y: 200, width: 200, height: 50)
    button.setTitle("New Activity", for: UIControl.State.normal)
    button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = UIColor.orange
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainScreen.handleNewActivity(_:))))
        //button.addTarget(self, action: #selector(MainScreen.newActivity), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        let label: UILabel = UILabel(frame: CGRect(x: view.center.x-100, y: 275, width: 200, height: 50))
        label.text = "Activity Table"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        
        activityTableView.frame = CGRect(x: view.center.x-150, y: 325, width: 300, height: 350)
        activityTableView.dataSource = self
        activityTableView.delegate = self
        activityTableView.backgroundColor = UIColor.white
        view.addSubview(activityTableView)
        
        button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 700, width: 200, height: 50)
        button.setTitle("Settings", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = UIColor.orange
      //  button.addTarget(self, action: #selector(MainScreen.clearActivities), for: UIControl.Event.touchUpInside)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainScreen.handleTap(_:))))
        view.addSubview(button)

        createDirectory()
        restoreFromFile()
        print("File contents:")
        for activity in activityList {
            print("\(activity.workout): for \(activity.time)")
        }
        
        openDB()
        restoreFromDB()
        print("Database contents:")
        for activity in activityList {
            print("\(activity.workout): for \(activity.time)")
        }
    }
    
    @objc func handleNewActivity(_ recognizer: UITapGestureRecognizer) {
        let nac: NewActivity = NewActivity()
          nac.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
          nac.modalPresentationStyle = UIModalPresentationStyle.fullScreen
          present( nac, animated: true, completion: {
              () -> Void in
          })
          
      }
    
    @objc func changeBackgroundColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
       let svc: SettingsViewController = SettingsViewController()
        svc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        svc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present( svc, animated: true, completion: {
            () -> Void in
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ActivityCell)
        let activity: Activity
        activity = activityList[indexPath.row]
        cell.textLabel?.text = activity.workout
        return cell
    }
    
    private func displayDirectory() {
        print("Absolute path for Home Directory: \(NSHomeDirectory())")
        if let dirEnumerator = FileManager.default.enumerator(atPath: NSHomeDirectory()) {
            while let currentPath = dirEnumerator.nextObject() as? String {
                print(currentPath)
            }
        }
    }
    
    private func createDirectory() {
        print("Before directory is created...")
        displayDirectory()
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
            if isDir.boolValue {
                print("\(dirPath) exists and is a directory")
            }
            else {
                print("\(dirPath) exists and is not a directory")
            }
        }
        else {
            print("\(dirPath) does not exist")
            do {
                try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Error creating directory \(dirPath): \(error)")
            }
        }
        print("After directory is created...")
        displayDirectory()
    }
    
    private func saveToFile() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: activityList, requiringSecureCoding: false)
            if FileManager.default.createFile(atPath: filePath,
                                      contents: data,
                                      attributes: nil) {
                print("File \(filePath) successfully created")
            }
            else {
                print("File \(filePath) could not be created")
            }
        }
        catch {
            print("Error archiving data: \(error)")
        }
    }
    
    private func restoreFromFile() {
        do {
            if let data = FileManager.default.contents(atPath: filePath) {
                print("Retrieving data from file \(filePath)")
                activityList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Activity] ?? [Activity]()
            }
            else {
                print("No data available in file \(filePath)")
                activityList = [Activity]()
            }
            activityTableView.reloadData()
        }
        catch {
            print("Error unarchiving data: \(error)")
        }
    }
    
    private func deleteFile() {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch {
            print("Error deleting file: \(error)")
        }
    }
    
    private func openDB() {
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("activityDatabase.sqlite")
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS activity (id INTEGER PRIMARY KEY AUTOINCREMENT,workout TEXT, date text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error creating table: \(errmsg)")
            }
        }
        catch {
            print("Error opening database: \(error)")
        }
    }
    
    private func closeDB() {
        sqlite3_close(db)
    }
    
    func restoreFromDB() {
        activityList.removeAll()
        
        let queryString = "SELECT * FROM activity"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let workout = sqlite3_column_int(stmt, 0)
            let time = String(cString: sqlite3_column_text(stmt, 1))
            
            //activityList.append(Activity(workout: workout, time: time))
        }
        sqlite3_finalize(stmt)
        
        activityTableView.reloadData()
    }
    
    @objc func clearActivities() {
        activityList.removeAll()

        if sqlite3_exec(db, "DELETE FROM Activity", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error deleting table: \(errmsg)")
        }
        
        deleteFile()
        
        activityTableView.reloadData()
    }
  
    
}
















class NewActivity: UIViewController, UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    let dirPath: String = "\(NSHomeDirectory())/tmp"
    let filePath: String = "\(NSHomeDirectory())/tmp/person.txt"
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (component == 0) ? times.count : minutes.count

    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (component == 0) ? 200.0 : 100.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (component == 0) ? times[row] : minutes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let time: String = times[pickerView.selectedRow(inComponent: 0)]
            
            pickerView.reloadComponent(1)
        }
        print("Selected row \(row) in component \(component)...")
    }
    
    
    
    let times: [String] = ["1:","2:","3:","4:","5:","6:","7:","8:","9:","10:","11:","12:"]
    var minutes: [String] = ["00","15","30","45"]
    
    let workoutTextField: UITextField = UITextField()
    let dateTextField: UITextField = UITextField()
    var db: OpaquePointer?
    var activityList = [Activity]()

    override func viewDidLoad() {
        view.backgroundColor = UIColor.yellow
        
        let pickerView: UIPickerView = UIPickerView(frame: CGRect.zero)
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.center.x = view.center.x
            pickerView.center.y = view.center.y
            view.addSubview(pickerView)
    
    /*
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return (component == 0) ? times.count : minutes.count
        }
      */
        

        
        workoutTextField.frame = CGRect(x: view.center.x-135, y: 150, width: 270, height: 50)
        workoutTextField.textColor = UIColor.black
        workoutTextField.font = UIFont.systemFont(ofSize: 24.0)
        workoutTextField.placeholder = "<Enter Workout>"
        workoutTextField.backgroundColor = UIColor.white
        workoutTextField.keyboardType = UIKeyboardType.default
        workoutTextField.returnKeyType = UIReturnKeyType.done
        workoutTextField.clearButtonMode = UITextField.ViewMode.always
        workoutTextField.layer.borderColor = UIColor.black.cgColor
        workoutTextField.borderStyle = UITextField.BorderStyle.line
        workoutTextField.layer.borderWidth = 1
        workoutTextField.delegate = self
        view.addSubview(workoutTextField)
        
        dateTextField.frame = CGRect(x: view.center.x-135, y: 225, width: 270, height: 50)
        dateTextField.textColor = UIColor.black
        dateTextField.font = UIFont.systemFont(ofSize: 24.0)
        dateTextField.placeholder = "<enter date>"
        dateTextField.backgroundColor = UIColor.white
        dateTextField.keyboardType = UIKeyboardType.default
        dateTextField.returnKeyType = UIReturnKeyType.done
        dateTextField.clearButtonMode = UITextField.ViewMode.always
        dateTextField.borderStyle = UITextField.BorderStyle.line
        dateTextField.layer.borderColor = UIColor.black.cgColor
        dateTextField.layer.borderWidth = 1
        dateTextField.delegate = self
        view.addSubview(dateTextField)
        
        var button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 800, width: 200, height: 50)
        button.setTitle("ADD", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(NewActivity.addActivity), for: UIControl.Event.touchUpInside)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewActivity.handleTap(_:))))
        view.addSubview(button)
        
        let label: UILabel = UILabel(frame: CGRect(x: view.center.x-100, y: 325, width: 200, height: 50))
        label.text = "Select Time"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.white
        view.addSubview(label)
        
    }
    
    @objc func changeBackgroundColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    
    private func displayDirectory() {
        print("Absolute path for Home Directory: \(NSHomeDirectory())")
        if let dirEnumerator = FileManager.default.enumerator(atPath: NSHomeDirectory()) {
            while let currentPath = dirEnumerator.nextObject() as? String {
                print(currentPath)
            }
        }
    }
    
    private func createDirectory() {
        print("Before directory is created...")
        displayDirectory()
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
            if isDir.boolValue {
                print("\(dirPath) exists and is a directory")
            }
            else {
                print("\(dirPath) exists and is not a directory")
            }
        }
        else {
            print("\(dirPath) does not exist")
            do {
                try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Error creating directory \(dirPath): \(error)")
            }
        }
        print("After directory is created...")
        displayDirectory()
    }
    
    private func saveToFile() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: activityList, requiringSecureCoding: false)
            if FileManager.default.createFile(atPath: filePath,
                                      contents: data,
                                      attributes: nil) {
                print("File \(filePath) successfully created")
            }
            else {
                print("File \(filePath) could not be created")
            }
        }
        catch {
            print("Error archiving data: \(error)")
        }
    }
    
    private func restoreFromFile() {
        let main : MainScreen = presentingViewController as! MainScreen
        do {
            if let data = FileManager.default.contents(atPath: filePath) {
                print("Retrieving data from file \(filePath)")
                activityList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Activity] ?? [Activity]()
            }
            else {
                print("No data available in file \(filePath)")
                activityList = [Activity]()
            }
            main.activityTableView.reloadData()
        }
        catch {
            print("Error unarchiving data: \(error)")
        }
    }
    
    private func deleteFile() {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch {
            print("Error deleting file: \(error)")
        }
    }
    
    private func openDB() {
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("activityDatabase.sqlite")
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS activity (id INTEGER PRIMARY KEY AUTOINCREMENT,workout TEXT, date text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error creating table: \(errmsg)")
            }
        }
        catch {
            print("Error opening database: \(error)")
        }
    }
    
    private func closeDB() {
        sqlite3_close(db)
    }
    
    func restoreFromDB() {
        
        let main : MainScreen = presentingViewController as! MainScreen
        
        activityList.removeAll()
        
        let queryString = "SELECT * FROM activity"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let workout = sqlite3_column_int(stmt, 0)
            let time = String(cString: sqlite3_column_text(stmt, 1))
            
            //main.append(Activity(workout: workout, time: time))
        }
        sqlite3_finalize(stmt)
        
        main.activityTableView.reloadData()
    }
    
    
        @objc func addActivity() {
            
            if let workout = workoutTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !workout.isEmpty {
                workoutTextField.layer.borderWidth = 1
                workoutTextField.layer.borderColor = UIColor.black.cgColor
                if let dateString = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !dateString.isEmpty {
                    dateTextField.layer.borderWidth = 1
                    dateTextField.layer.borderColor = UIColor.black.cgColor
                    if let time = workoutTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !time.isEmpty {
                    workoutTextField.layer.borderWidth = 1
                    workoutTextField.layer.borderColor = UIColor.black.cgColor
                    var stmt: OpaquePointer?
                    var queryString = "SELECT * FROM Activity WHERE Workout = '\(workout)'"
                    if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error preparing select: \(errmsg)")
                        return
                    }
                    if sqlite3_step(stmt) == SQLITE_ROW {
                        print("\(workout) already in DB")
                        let id = sqlite3_column_int(stmt, 0)
                        sqlite3_finalize(stmt)
                        queryString = "UPDATE workout = \(time) Time = \(String(describing: time))"
                        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("error preparing update: \(errmsg)")
                            return
                        }
                        if sqlite3_step(stmt) != SQLITE_DONE {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure updating activity: \(errmsg)")
                            return
                        }
                        sqlite3_finalize(stmt)
                        /*
                        for activity in activityList {
                            if activity.workout == workout {
                                activity.time = time
                            }
                        }
                        */
                    }
                    else {
                        print("adding \(workout) to DB")
                        sqlite3_finalize(stmt)
                        queryString = "INSERT Activity (workout, date, time) VALUES (?,?,?)"
                        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("error preparing insert: \(errmsg)")
                            return
                        }
                        if sqlite3_bind_text(stmt, 1, workout, -1, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("failure binding workout: \(errmsg)")
                            return
                        }
                        if sqlite3_bind_text(stmt, 2, dateString, -1, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("failure binding date: \(errmsg)")
                            return
                        }
                        if sqlite3_bind_text(stmt, 3, time, -1, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("failure binding date: \(errmsg)")
                            return
                        }
                        
                        /*
                        if sqlite3_bind_int(stmt, 2, time) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db))
                            print("failure binding date: \(errmsg)")
                            return
                        }
 */
                        if sqlite3_step(stmt) != SQLITE_DONE {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure inserting workout: \(errmsg)")
                            return
                        }
                        sqlite3_finalize(stmt)
                        queryString = "SELECT * FROM Activity WHERE Workout = '\(workout)'"
                        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("error preparing select: \(errmsg)")
                            return
                        }
                        
                        if sqlite3_step(stmt) == SQLITE_ROW {
                            let time = sqlite3_column_int(stmt, 0)
                            activityList.append(Activity(workout: workout, time: ""))
                        }
 
                        sqlite3_finalize(stmt)
                    }
                    
                    workoutTextField.text = ""
                    dateTextField.text = ""

                    saveToFile()
                        let main : MainScreen = presentingViewController as! MainScreen
                       main.activityTableView.reloadData()
                }
                else {
                    dateTextField.layer.borderWidth = 3
                    dateTextField.layer.borderColor = UIColor.red.cgColor
                }
            }
            else {
                workoutTextField.layer.borderWidth = 3
                workoutTextField.layer.borderColor = UIColor.red.cgColor
            }
            
            
            
            }
            
        }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: {() -> Void in
            print("Modal view controller dismissed...")
        })
    }

    }
    
    
//}

class Activity: NSObject, NSCoding {
        let workoutType: String = "Workout Type"
        let activityTime: String = "Time of Activity"
        
        let workout: String?
        let time: String?
        
        init(workout: String, time: String) {
            self.workout = workout
            self.time = time
        }
        
        required init?(coder aDecoder: NSCoder) {
            workout = aDecoder.decodeObject(forKey: workoutType) as? String
            time = aDecoder.decodeObject(forKey: activityTime) as? String
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(workout, forKey: workoutType)
            aCoder.encode(time, forKey: activityTime)
        }
}
 












class SettingsViewController: UIViewController {
    static let sharedInstance = SettingsViewController()
    var backgroundColor = UIColor.white
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.orange
        
        let red = UIView()
        red.backgroundColor = UIColor.red
        red.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(red)
        let blue = UIView()
        blue.backgroundColor = UIColor.blue
        blue.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blue)
        
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissViewController(_:))))
        
        
        
        /*
        let backButton = UIButton()
        backButton.setTitle("Return", for: .normal)
        backButton.backgroundColor = UIColor.blue
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.isEnabled = true
        backButton.addTarget(self, action: #selector(handleTap()), for: UIControl.Event.touchUpInside)
        view.addSubview(backButton)
        view.addConstraints([
            NSLayoutConstraint(item: backButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 130),
        NSLayoutConstraint(item: backButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50),
        NSLayoutConstraint(item: backButton, attribute: .centerX, relatedBy: .equal, toItem: red, attribute: .centerX, multiplier: 1.0, constant: 100),
        NSLayoutConstraint(item: backButton, attribute: .topMargin, relatedBy: .equal, toItem: red, attribute: .topMargin, multiplier: 1.0, constant: 50)
        ])
        */
        let clearButton = UIButton()
        clearButton.setTitle("Clear Activities", for: .normal)
        clearButton.backgroundColor = UIColor.blue
        clearButton.setTitleColor(UIColor.white, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.isEnabled = true
        clearButton.addTarget(self, action: #selector(MainScreen.clearActivities), for: UIControl.Event.touchUpInside)
        view.addSubview(clearButton)
        view.addConstraints([
            NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 180),
            NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50),
            NSLayoutConstraint(item: clearButton, attribute: .centerX, relatedBy: .equal, toItem: red, attribute: .centerX, multiplier: 1.0, constant: 215),
            NSLayoutConstraint(item: clearButton, attribute: .topMargin, relatedBy: .equal, toItem: red, attribute: .topMargin, multiplier: 1.0, constant: 600)
            ])
        /*
        let colorButton = UIButton()
        colorButton.frame = CGRect(x: view.center.x, y: view.center.y, width: 200, height: 50)
        colorButton.setTitle("Change Background", for: .normal)
        colorButton.backgroundColor = UIColor.blue
        colorButton.setTitleColor(UIColor.white, for: .normal)
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        colorButton.isEnabled = true
        colorButton.addTarget(self, action: #selector(SettingsViewController.changeColor), for: UIControl.Event.touchUpInside)
        view.addSubview(colorButton)
        */
        let colorButton = UIButton(type: UIButton.ButtonType.custom)
        colorButton.frame = CGRect(x: view.center.x-100, y: 200, width: 200, height: 50)
        colorButton.setTitle("Change Color", for: UIControl.State.normal)
        colorButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        colorButton.backgroundColor = UIColor.blue
        colorButton.isEnabled = true
        colorButton.addTarget(self, action: #selector(SettingsViewController.changeColor), for: UIControl.Event.touchUpInside)
        view.addSubview(colorButton)
        
        
        
        /*
        let mySwitch = UISwitch()
        mySwitch.isOn = true
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addControlEventRecognizer(.valueChanged, action: {() -> () in
            if let color: UIColor = red.backgroundColor {
                red.backgroundColor = blue.backgroundColor
                blue.backgroundColor = color
            }
        })
    
        
        view.addSubview(mySwitch)
               view.addConstraints([
                   NSLayoutConstraint(item: mySwitch, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
                   NSLayoutConstraint(item: mySwitch, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 50)
                   ])
        */
        
    }
    @objc func changeColor(sender: UIButton){
        let newMain : MainScreen = presentingViewController as! MainScreen
        let newActivityScreen : NewActivity = NewActivity()
        newMain.changeBackgroundColor(color: UIColor.white)
        newActivityScreen.changeBackgroundColor(color: UIColor.white)
        SettingsViewController.sharedInstance.backgroundColor = UIColor.white
        self.view.backgroundColor = SettingsViewController.sharedInstance.backgroundColor
        print("Color button pushed")
    }
    
// Return to previous view controller when user swipes right
@objc func dismissViewController(_ recognizer: UISwipeGestureRecognizer) {
    presentingViewController?.dismiss(animated: true, completion: {() -> Void in
        print("Modal view controller dismissed...")
    })
}
    
}



extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - (size.width / 2), y: center.y - (size.height / 2)), size: size)
    }
    init(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(x: centerX - (width / 2), y: centerY - (height / 2), width: width, height: height)
    }
}

extension UIControl {
    private struct AssociatedObjectKeys {
        static var controlEventRecognizer = "ControlEventAssociatedObjectKey"
    }
    
    private var controlEventAction: (() -> Void)? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.controlEventRecognizer, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let controlEventActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.controlEventRecognizer) as? (() -> Void)
            return controlEventActionInstance
        }
    }
    
    public func addControlEventRecognizer(_ event: UIControl.Event, action: (() -> Void)?) {
        isUserInteractionEnabled = true
        controlEventAction = action
        addTarget(self, action: #selector(handleControlEvent), for: event)
    }
    
    @objc private func handleControlEvent() {
        if let action = controlEventAction {
            action()
        }
    }
    
}

extension UIView {
    private struct TapAssociatedObjectKeys {
        static var gestureRecognizer = "TapGestureAssociatedObjectKey"
    }
    private var tapGestureRecognizerAction: ((_ recognizer: UITapGestureRecognizer) -> Void)? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &TapAssociatedObjectKeys.gestureRecognizer, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &TapAssociatedObjectKeys.gestureRecognizer) as? ((_ recognizer: UITapGestureRecognizer) -> Void)
            return tapGestureRecognizerActionInstance
        }
    }
    public func addTapGestureRecognizer(action: ((_ recognizer: UITapGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action(recognizer)
        }
    }
    
    private struct PanAssociatedObjectKeys {
        static var gestureRecognizer = "PanGestureAssociatedObjectKey"
    }
    private var panGestureRecognizerAction: ((_ recognizer: UIPanGestureRecognizer) -> Void)? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &PanAssociatedObjectKeys.gestureRecognizer, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let panGestureRecognizerActionInstance = objc_getAssociatedObject(self, &PanAssociatedObjectKeys.gestureRecognizer) as? ((_ recognizer: UIPanGestureRecognizer) -> Void)
            return panGestureRecognizerActionInstance
        }
    }
    public func addPanGestureRecognizer(action: ((_ recognizer: UIPanGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.panGestureRecognizerAction = action
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if let action = self.panGestureRecognizerAction {
            action(recognizer)
        }
    }
    
    private struct SwipeAssociatedObjectKeys {
        static var gestureRecognizer = "SwipeGestureAssociatedObjectKey"
    }
    private var swipeGestureRecognizerAction: ((_ recognizer: UISwipeGestureRecognizer) -> Void)? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &SwipeAssociatedObjectKeys.gestureRecognizer, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let swipeGestureRecognizerActionInstance = objc_getAssociatedObject(self, &SwipeAssociatedObjectKeys.gestureRecognizer) as? ((_ recognizer: UISwipeGestureRecognizer) -> Void)
            return swipeGestureRecognizerActionInstance
        }
    }
    public func addSwipeGestureRecognizer(action: ((_ recognizer: UISwipeGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.swipeGestureRecognizerAction = action
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        self.addGestureRecognizer(swipeGestureRecognizer)
    }
    @objc private func handleSwipeGesture(_ recognizer: UISwipeGestureRecognizer) {
        if let action = self.swipeGestureRecognizerAction {
            action(recognizer)
        }
    }
}

