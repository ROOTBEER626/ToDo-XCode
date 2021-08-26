//
//  DoEditViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 12/31/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit
import CoreData

class DoEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    //outlets for the userInterface
    
    //shows the name of the do
    @IBOutlet weak var nameField: UITextField!
    
    //shows the bio of the do
    @IBOutlet weak var bioView: UITextView!
    
    //shows the completion status of the do
    @IBOutlet weak var completionStatus: UIButton!
    
    //shows the date that the do was created
    @IBOutlet weak var dateCreated: UILabel!
    
    //variable to hold the do we are editing
    var currentDo: Do?
    var currentProject: Project?
    
    //variables to hold the data of the currentDo before the editing
    var currentName: String?
    var currentBio: String?
    var currentStatus: Bool?
    var doDate: Date?
    
    //reference to the persistent container needed for core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //assign the currentValues of my do to my variables above and fill in the textfields and views
        if let descriptor = self.currentDo?.name{
            currentName = descriptor
            nameField.text = descriptor
        }
        else{
            currentName = ""
            nameField.placeholder = "Please Enter a Name"
        }
        if let descriptor = self.currentDo?.bio{
            currentBio = descriptor
            bioView.text = descriptor
        }
        else{
            currentBio = ""
            bioView.text = "Please Describe what you have ToDo"
        }
        if self.currentDo?.completionStatus == true{
                self.completionStatus.setTitle("Complete", for: .normal)
        }
        else{
                self.completionStatus.setTitle("Incomplete", for: .normal)
            }
    }
    
    //the below function will clear the textfield  and textview respectivelty when the user clicks on it to edit.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //this is not really needed as the placeholder value is replaced when the user begins typing anyway
        textField.placeholder = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
    }
    
    @IBAction func completeTapped(_ sender: UIButton) {
           let completionCheck = self.currentDo?.completionStatus
           if completionCheck == true{
               self.completionStatus.setTitle("Incomplete", for: .normal)
               self.currentDo?.completionStatus = false
           }
           else if completionCheck == false{
               self.completionStatus.setTitle("Complete", for: .normal)
               self.currentDo?.completionStatus = true
           }
           do{
               try self.context.save()
           }
           catch{
               //catch erros here
           }
       }
    
    //actions that the view will use
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        //check if changes have been made and if so alert the user and give a choice of saving or undoing the changes and going back or just cancelling the back button click
        //first check if changes have been made
        if self.nameField.text != currentName || self.bioView.text != currentBio{
            let alert = UIAlertController(title: "Changes have been made", message:  "What would you like to do", preferredStyle: .alert)
            let saveButton = UIAlertAction(title: "Save", style: .default){ (action) in
                self.saveChanges()
                self.popself()
            }
            let undoButton = UIAlertAction(title: "Undo Changes", style: .default){ (action) in
                self.undoChanges()
                self.popself()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .default){ (action) in
                //dont need to do anything
            }
            //add buttons to alert and present alert
            alert.addAction(saveButton)
            alert.addAction(undoButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
        //pop the current viewController
        self.popself()
    }
    
    @IBAction func saveChangesTapped(_ sender: Any) {
        //update the data in coreData
        let alert = UIAlertController(title: "Save Changes", message: "Are you sure you want to save the changes made", preferredStyle: .alert)
        //configure the save button handler)
        let saveButton = UIAlertAction(title: "Save", style: .default){ (action) in
            self.saveChanges()
        }
            //configure cancel button
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
            //dont need to do anything here
        }
        //add buttons to alert
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func undoChangesTapped(_ sender: UIButton) {
        //revert back to the data that we had before the changes were made
        undoChanges()
    }
    
    
    
    //functions used in actions
    //function to save changes made
    func saveChanges(){
        //save changes made to currentDo
        let newName = self.nameField.text
        let newBio = self.bioView.text
        self.currentName = newName
        self.currentBio = newBio
        //assign the new values ot our currentDo
        self.currentDo?.name = newName
        self.currentDo?.bio = newBio
        //save the updated data into CoreDATA
        do{
            try self.context.save()
        }
        catch{
            //catch errors here
        }
    }
    
    //function to undoChanges made
    func undoChanges(){
        self.nameField.text = currentName
        self.bioView.text = currentBio
    }
    
    //function to go back to the previous view. Ensures that the do changed will be updated
    func popself(){
        let vc = self.navigationController!.viewControllers[1] as! DoViewController
        //vc.currentDo = self.currentDo
        //vc.currentProject = self.currentProject
        vc.loadDos(project: currentProject!)
        //vc.fetchDos()
        self.navigationController!.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
