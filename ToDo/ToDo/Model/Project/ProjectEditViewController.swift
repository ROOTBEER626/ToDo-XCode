//
//  ProjectEditViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 12/30/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit
import CoreData

class ProjectEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //outlets for the userInterface
    
    //shows the name of the project
    @IBOutlet weak var nameField: UITextField!
    
    //shows the bio of the project
    @IBOutlet weak var bioView: UITextView!
    
    //shows the completion status of the project
    @IBOutlet weak var completionStatus: UIButton!
    
    //shows the date the project was created
    @IBOutlet weak var dateCreated: UILabel!
    
    //variable to hold the Project we are editing
    var currentProject: Project?
    //variables to hold the data of the currentProject before the editing
    var currentName: String?
    var currentBio: String?
    var currentStatus: Bool?
    var projectDate: Date?
    
    //reference to the persistent container needed for core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //assign the currentVlaues of my project to my variables above and fill in the textFields and Views
        if self.currentProject != nil{
            if let descriptor = self.currentProject?.name{
                currentName = descriptor
                nameField.text = descriptor
            }
            else{
                currentName = ""
                nameField.placeholder = "Please Enter A Name"
            }
            if let descriptor = self.currentProject?.bio{
                currentBio = descriptor
                bioView.text = descriptor
            }
            else{
                currentBio = ""
                //currently will have the bioView.text have no text when no bio is entered because I cannot yet have the what is in the bio fully deleted when the user is entering his own bio and that seems inconvienent
            }
            //current attempt to get around not being able to assign the value.
            //the problem is that I can not assign the YES/NO value to the switch it is based off of user input so how will I be able to initlizde it for the view.
            if self.currentProject?.completionStatus == true{
                self.completionStatus.setTitle("Complete", for: .normal)
            }
            else{
                self.completionStatus.setTitle("Incomplete", for: .normal)
            }
            //Going to initilize the values of date and completion status after I implement them into my coreData entities
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
    
    //action for when the complete button is tapped
    //will need to change the value of the currentProjects CompletionStatus and change the text shown on the completionButton
    @IBAction func completeTapped(_ sender: UIButton) {
        let completionCheck = self.currentProject?.completionStatus
        if completionCheck == true{
            self.completionStatus.setTitle("Incomplete", for: .normal)
            self.currentProject?.completionStatus = false
        }
        else if completionCheck == false{
            self.completionStatus.setTitle("Complete", for: .normal)
            self.currentProject?.completionStatus = true
        }
        do{
            try self.context.save()
        }
        catch{
            //catch erros here
        }
    }
    
    //all of the actions that this view will use
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
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
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
    
    //function to save changes
    func saveChanges(){
    //save changes made to current Project
        //get the date we are saving
        let newName = self.nameField.text
        let newBio = self.bioView.text
        self.currentName = newName
        self.currentBio = newBio
        //assign the new Values to our currentProject
        self.currentProject?.name = newName
        self.currentProject?.bio = newBio
        //save the new Data into CoreData
        do{
            try self.context.save()
        }
        catch{
            //catch erros here
        }
    }
    
    //not needed as we should be poping this view not pushing another instance of the previous view on top of it
    //function to go back to the previous view
//    func reinsateView(){
//        let vc = storyboard!.instantiateViewController(withIdentifier: "DoView") as! DoViewController
//        vc.currentProject = self.currentProject
//        //ensure that the DoView will take up the full screen
//        vc.modalPresentationStyle = .fullScreen
//        //push the view controller onto the view and ensure that the navigationController shows
//        self.navigationController!.pushViewController(vc, animated: true)
//    }
    
    //function to undoChanges
    func undoChanges(){
        self.nameField.text = currentName
        self.bioView.text = currentBio
    }
    
    //function to go back to the previous view. Ensures that the project changed will be updated in the DoView
    func popself(){
        let vc = self.navigationController!.viewControllers[1] as! DoViewController
        vc.currentProject = self.currentProject
        vc.projectTitle.title = self.currentProject?.name
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
