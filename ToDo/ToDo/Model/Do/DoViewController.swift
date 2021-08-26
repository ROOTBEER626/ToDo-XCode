//
//  DoViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 12/9/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit
import CoreData
import SQLite3

class DoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //outlet to connect to the table
    @IBOutlet var doTable: UITableView!
    
    //Outlet to show the currentProject
    @IBOutlet weak var projectTitle: UINavigationItem!
    
    
    //The array that will populate our table
    var dos:[Do]?
    
    //The variable that will store the value of the current Project that we are in
    var currentProject: Project?
    var currentDo: Do?
    
    //reference to the persistant container needed for core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(currentProject!)
        // Do any additional setup after loading the view.
        doTable.delegate = self
        doTable.dataSource = self
        
        //this is the function I chose to run instead of fetchDos() to get the dos needed to populate my table
        loadDos(project: currentProject!)
        //fetchDos()
    
        //set the title of the view
        projectTitle.title = currentProject?.name
    }
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped( _sender: UIBarButtonItem){
        self.popself()
    }
    
//    func fetchDos(){
//         do{
//            let request = Do.fetchRequest() as NSFetchRequest<Do>
//            let pred = NSPredicate(format: "home.name == %@", "self.currentProject.name")
//            request.predicate = pred
//            self.dos = try context.fetch(request)
//            //reloads data
//            //only want this done by the main thread
//            DispatchQueue.main.async {
//                self.doTable.reloadData()
//            }
//         }
//         catch{
//             //catch errors here
//             //I havent found any errors to catch when fetching
//         }
//
//     }
    
    //this is the function that will populate my dos array with the dos the project has
    //much easier to use my coreData entities relationships instead of trying to filter the fetch request
    func loadDos(project: Project){
        dos = currentProject?.dos?.allObjects as? [Do]
        //call sort function here
        DispatchQueue.main.async {
            self.doTable.reloadData()
        }
    }
    
    //allows the user to edit the currentProjects name and description
    //Going to switch the functionality to segue to the editView
    @IBAction func editProject(_ sender: UIBarButtonItem) {
        //create a variable to store the currentProject
        //we already have one know as currentProject
        //instatiate the editView
        let vc = storyboard!.instantiateViewController(withIdentifier: "ProjectEditView") as! ProjectEditViewController
        //assign the variables of our currentProject to
        vc.currentProject = self.currentProject
        //ensure that the EditView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view and ensure that the navigationController shows
        self.navigationController!.pushViewController(vc, animated: true)
        }
    
    //allows the user to create a new Do
    @IBAction func addTapped(_ sender: UIButton) {
        //we want to send the user to the DoCreationView so that they can create a new Do for the currentProject
        //we will need to instantiate the DoCreationView and pass the currentProjectValue to the view
        let vc = storyboard!.instantiateViewController(withIdentifier: "DoCreationView") as! DoCreationViewController
        //send the value of the currentProject to the DoCreationView
        vc.currentProject = self.currentProject
        //ensure that the EditView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view and ensure that the navigationController shows
        self.navigationController!.pushViewController(vc, animated: true)
        //when does this happen
        print("Gonna load dos")
        self.loadDos(project: currentProject!)
        //self.fetchDos()
    }
    
    
    
    //return the count of dos in the current project
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
        return (self.dos?.count ?? 0)//default value to 0 for when there are no dos in the optional
    }
    
    //fills the tableView with the dos
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let placeholder = self.dos?[indexPath.row]
        cell.textLabel?.text = placeholder?.name
        if placeholder?.completionStatus == true{
            cell.backgroundColor = .red
        }
        return cell
    }
    
    //When a row is selected the user will be able to edit the name and bio of the do
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //create a variable to store the currentDo
        currentDo = self.dos?[indexPath.row]
        let vc = storyboard!.instantiateViewController(withIdentifier: "DoEditView") as! DoEditViewController
        //asssing the variables of our currentDo
        vc.currentDo = self.currentDo
        vc.currentProject = self.currentProject
        //ensire that the EditView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view and ensure that the navigation bar shows
        self.navigationController!.pushViewController(vc, animated: true)
        self.loadDos(project: currentProject!)
        //self.fetchDos()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //leading swipe action delete project
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration?  {
        //creat action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            //get reference to project to remove
            let doToRemove = self.dos![indexPath.row]
            let alert = UIAlertController(title: "Delete Do", message: "Are you sure you want to delete this do?", preferredStyle: .alert)
            //create delete button
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ (deleteAction) in
                //try to remove using NSSet
                self.currentProject?.removeFromDos(doToRemove)
                //delete the project
                self.context.delete(doToRemove)
                //save to coreData
                do{
                    try self.context.save()
                }
                catch{
                    //catch save errors here
                    //I havent found any errors to catch when saving
                    }
                //refresh tableView
                //self.fetchDos()
                self.loadDos(project: self.currentProject!)
                //the below works and deleted the do
                //but it does not bring the user back to the ProjectView
                //it also does not remove the project from the ProjectView until the app is closed and reopened
                if self.currentProject?.dos?.count ?? 0 < 1{
                let alert = UIAlertController(title: "Project is now Empty", message: "Would you like to delete this Project", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ (deleteAction) in
                   //delete project
                    self.context.delete(self.currentProject!)
                        //save to coreData
                        do{
                            try self.context.save()
                        }
                        catch{
                            //catch save errors here
                            //I havent found any errors to catch when saving
                        }
                    //go back to ProjectView here
                    self.popself()
                    //problem is the way that I am going back to the ProjectView is thorugh the viewNavigation
                    //going to have to set that up in a way where I get to create the action to go back
                    }
                let cancelAction = UIAlertAction(title: "Cancel",style: .cancel)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true,completion: nil)
                }
                
                   }
            //create cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //trailing swipe action complete project
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
        //create action
        let action = UIContextualAction(style: .destructive, title: "Complete Do") { (action, view, completionHandler) in
            //get reference to projecet to complete
            let doToComplete = self.dos![indexPath.row]
            //before we complete check if there are still Dos in the project and ask the user if they are sure
            let alert = UIAlertController(title: "Complete Do", message: "Have you completed this task?", preferredStyle: .alert)
            //create complete button
            let completeAction = UIAlertAction(title: "Complete", style: .destructive) { (completeAction) in
                //complete project
                //remove the do from the currentProjects dos and delete it from core data
                //try to remove using NSSet
                self.currentProject?.removeFromDos(doToComplete)
                self.context.delete(doToComplete)
                //save to coreData
                do{
                    try self.context.save()
                }
                catch{
                    //catch save errors here
                    //I havent found any errors to catch when saving
                }
            //refresh table
                //self.fetchDos()
                self.loadDos(project: self.currentProject!)
            //see comments in the above function
            if self.currentProject?.dos?.count ?? 0 < 1{
                let alert = UIAlertController(title: "Project is now Empty", message: "Would you like to complete your Project", preferredStyle: .alert)
                let completeAction = UIAlertAction(title: "Delete", style: .destructive){ (deleteAction) in
                   //delete project
                    self.context.delete(self.currentProject!)
                        //save to coreData
                        do{
                            try self.context.save()
                        }
                        catch{
                            //catch save errors here
                            //I havent found any errors to catch when saving
                        }
                    //go back to ProjectView here
                    self.popself()
                    //problem is the way that I am going back to the ProjectView is thorugh the viewNavigation
                    //going to have to set that up in a way where I get to create the action to go back
                    }
                let cancelAction = UIAlertAction(title: "Cancel",style: .cancel)
                alert.addAction(completeAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true,completion: nil)
                }
            }
            //create cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(completeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        //set color of complete swipe action to blue
        action.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [action])
        }

    
    //this function will be used to return the user to the ProjectView
    //will be called in delete and complete project if there are no project remaing and the user wants to delete or complete the project
    func restoreProjectView(){
        //instantiate the DoVIew with a variable
        let vc = storyboard!.instantiateViewController(withIdentifier:"ProjectView") as! ProjectViewController
        //ensure that the DoView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view
        //vc.fetchProjects()
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func popself(){
        self.navigationController!.popViewController(animated: true)
    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigationoverride func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination
     // Pass the selected object to the new view controller.
    }
    */

}
