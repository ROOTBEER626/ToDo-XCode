//
//  DoCreationViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 12/31/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit
import CoreData

class DoCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //outlets needed to get the data
    //outlet for getting the name
    @IBOutlet weak var nameField: UITextField!
    
    //outlet for getting the project bio
    @IBOutlet weak var bioView: UITextView!
    
    //outlet for showing the date
    @IBOutlet weak var dateCreated: UILabel!
    
    //variable to hold the Do created
    var currentDo: Do?
    //var to hold the currentProject that the Do will be contained in
    var currentProject: Project?
    
    //reference to persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        bioView.isSelectable = true

        nameField.placeholder = "Please Enter a Name"
        // Do any additional setup after loading the view.
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
    @IBAction func backTapped(_ sender: UIBarButtonItem){
        //check if the user has filled out the necessary data to create a new Do
        //lets place this into a guard statement to avoid finding nil
        if self.nameField.text != ""{
        //if self.nameField.text != "" || self.bioView.text != ""{
            let alert = UIAlertController(title: "New Do", message: "Would you like to save your new Do", preferredStyle: .alert)
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
    
    @IBAction func saveChangesTapped(_sender: Any) {
        //save the newDo
        self.saveChanges()
        //then send the user back to the DoView so they can get on with their lives
        self.popself()
    }
    
    @IBAction func undoChangesTapped(_sender: UIButton) {
        undoChanges()
    }

    
    
    //functions to be used by the actions
    func saveChanges(){
        //will need to create the new do
        //first get the data that will be used for the new object
        //gonna have to check these using optional binding
        let newDo = Do(context: self.context)
        newDo.completionStatus = false
        guard let newName = self.nameField?.text else{
            return
            //send an error saying there is no name for the do
        }
            newDo.name = newName
        if let newBio = self.bioView?.text{
            newDo.bio = newBio
        }
        //add this do to the currentProjects Dos
        self.currentProject?.addToDos(newDo)
        //save into CoreData
        do{
            try self.context.save()
        }
        catch{
            //catch save errors here
        }
    }
    
    func undoChanges(){
        self.nameField.text = ""
        self.bioView.text = ""
    }
    
    func popself(){
        let vc = self.navigationController!.viewControllers[1] as! DoViewController
        vc.loadDos(project: currentProject!)
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
