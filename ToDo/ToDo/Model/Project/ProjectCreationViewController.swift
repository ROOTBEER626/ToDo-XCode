//
//  ProjectCreationViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 12/31/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit
import CoreData

class ProjectCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{

    //outlets needed to get the data
    //outlet for getting the name
    @IBOutlet weak var nameField: UITextField!
    
    //outlet for getting the project bio
    @IBOutlet weak var bioView: UITextView!
    
    //outlet for showing the date
    @IBOutlet weak var dateCreated: UILabel!
    
    //variable to hold the Project created
    var currentProject: Project?
    
    //reference to persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set up the placeholder for my name creation and put the current date as the date label
        nameField.placeholder = "Please Enter A Name"
        //dateCreated.text = today
    }
    //the below function will clear the textfield  and textview respectivelty when the user clicks on it to edit.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //this is not really needed as the placeholder value is replaced when the user begins typing anyway
        textField.placeholder = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
    }
    

    
    //actions that the view will use
    //Sends user back to the ProjectView after checking if changes have been made and asking the user what it wants to do with those changes
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        //check if the user has filled out the necessary data to create a new Project
        if self.nameField.text != ""{
            let alert = UIAlertController(title: "New Project", message: "Would you like to save your new project", preferredStyle: .alert)
            let saveButton = UIAlertAction(title: "Save", style: .default){ (action) in
                self.saveChanges()
                self.popself()
            }
            let noButton = UIAlertAction(title: "No", style: .default){ (action) in
                self.popself()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                //dont need to do anything
            }
            alert.addAction(saveButton)
            alert.addAction(noButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
        self.popself()
    }
    
    //saves the project and sends the user back to the ProjectView
    @IBAction func saveChangesTapped(_ sender: Any) {
        //save the new Project
        self.saveChanges()
        //then send the user back to the ProjectView so they can get on with their lives
        self.popself()
    }
    
    //clears the nameField and the BioView
    @IBAction func undoChangesTapped(_sender: UIButton){
        undoChanges()
    }
    
    
    //have to use optional binding here
    //or i will run into the fatal error when unwrapping the optional value.
    //first create the core Data entity and only add the name and bio if they have been added and only save if they pass the vibe check
    //functions that the actions will use
    func saveChanges(){
     //will need to create the new Project
        //first get the data that will be used for the new object
        //gonna have to check these using optional binding
        let newProject = Project(context: self.context)
        newProject.completionStatus = false
        guard let newName = self.nameField?.text else{
            return
            //send an error saying there is no name for the do
        }
            newProject.name = newName
        if let newBio = self.bioView?.text{
            newProject.bio = newBio
        }
        //add this do to the currentProjects Dos
        //save into CoreData
        do{
            try self.context.save()
        }
        catch{
            //catch save errors here
        }
    }
    
    func undoChanges() {
        self.nameField.text = ""
        self.nameField.placeholder = "Please enter a name."
        self.bioView.text = "Please describe what you have to do."
    }
    
    func popself(){
        //let vc = self.navigationController!.viewControllers[0] as! ProjectViewController
        self.navigationController!.popViewController(animated: true)
    }
    
//    func sendToEdit() {
//        //after we create the new Project we no longer want the user to be in the creatProject View. We want to send the data of the Project just created to the ProjectEditView so it can be reviewed.Scrach that after the project is created we should just pop this view so that the user can decide what they would like to do
//
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
