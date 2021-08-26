//
//  ViewController.swift
//  ToDo
//
//  Created by Vinny Asaro on 11/27/20.
//  Copyright © 2020 Vinny Asaro. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    //Outlet for the tableView
    @IBOutlet var projectTable: UITableView!
    
    //The array that will populate our table
    var projects:[Project]?
        
    //reference to the persistant container// needed for core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        //print("App started")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //set up my tableView
        projectTable.delegate = self
        projectTable.dataSource = self
        
        //gets all projects stored in core data and adds them to our array: projects
        fetchProjects()
    }
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    //returns all projects stored in coreData
    func fetchProjects(){
        do{
            self.projects = try context.fetch(Project.fetchRequest())
            //reloads data
            //only want this done by the main thread
            DispatchQueue.main.async {
                self.projectTable.reloadData()
            }
        }
        catch{
            //catch errors here
            //I havent found any errors to catch when fetching
        }
        
    }
    
    //allows the user to add a new project
    @IBAction func addTapped(_ sender: UIButton) {
        //will now go to the ProjectEditView to create a new Project
        let vc = storyboard!.instantiateViewController(withIdentifier: "ProjectCreationView") as! ProjectCreationViewController
        //ensure that the EditView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view and ensure that the navigationController shows
        self.navigationController!.pushViewController(vc, animated: true)
        
        //the belwo is old code that got the data for the new Project using an alert
//        //create alert
//        let alert = UIAlertController(title: "Add Project", message: "Name Project", preferredStyle: .alert)
//        //add a textField for the user to enter the projects name
//        alert.addTextField() { (projectNameTextField) in
//            projectNameTextField.placeholder = "Please enter your projects name."
//        }
//        //add another text field for the bio
//        alert.addTextField() { (projectBioTextField) in
//            projectBioTextField.placeholder = "Please describe the project"
//        }
//        //configure the button Handler
//        let submitButton = UIAlertAction(title: "Add", style: .default){ (action) in
//            //get textfield for the alert
//            let nametextfield = alert.textFields![0]
//            let biotextfield = alert.textFields![1]
//
//            //crete a new project
//            let newProject = Project(context: self.context)
//            //set newProjects name
//            if nametextfield.text == "" {
//                newProject.name = "No Name Project"
//            }
//            else{
//            newProject.name = nametextfield.text
//            }
//            //set newProjects bio
//            newProject.bio = biotextfield.text
//
//            //save into CoreData
//            do{
//                try self.context.save()
//            }
//            catch{
//                //catch save errors here
//                //I havent found any errors to catch when saving
//            }
//            //Refresh Table View
//            self.fetchProjects()
//        }
//        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
//            //dont need to do anythin here
//        }
//        //add buttons and show alert
//        alert.addAction(submitButton)
//        alert.addAction(cancelButton)
//        self.present(alert, animated: true, completion: nil)
    }
    
    
    //returns the count of the projects in our project array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
        return self.projects?.count ?? 0 //0 is the default value if there are no projects in the array
    }
    
    //fills the table with the projects
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //ensure we have the most up to date data
        self.fetchProjects()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let project = self.projects?[indexPath.row]
        cell.textLabel?.text = project?.name
        if project?.completionStatus == true{
            cell.backgroundColor = .red
        }
        return cell
    }
    
    //presents the DoViewController for the respective project that was clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //create a variable that holds the project that was clicked
        let cp = self.projects?[indexPath.row]
        //instantiate the DoView with a variable
        let vc = storyboard!.instantiateViewController(withIdentifier:"DoView") as! DoViewController
        //assign the variables currentProject variable to the project that was clicked
        vc.currentProject = cp
        //ensure that the DoView will take up the full screen
        vc.modalPresentationStyle = .fullScreen
        //push the view controller onto the view and ensure that the navigationController shows
        self.navigationController!.pushViewController(vc, animated: true)
        //deselect the Project
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //leading swipe action delete project
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
        //creat action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            //get reference to project to remove
            let projectToDelete = self.projects![indexPath.row]
            //check if the project still has dos
            if projectToDelete.dos?.count ?? 0 > 0{
                let alert = UIAlertController(title: "Warning", message: "This project still has dos, are you sure you want to delete it", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .default){ (deleteAction) in
                    //delete the project
                    self.context.delete(projectToDelete)
                    //save to coreData
                    do{
                        try self.context.save()
                    }
                    catch{
                        //catch save errors here
                        //I havent found any errors to catch when saving
                    }
                    //refresh tableView
                    self.fetchProjects()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this project?", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .default){ (completeAction) in
                    //delete project
                    self.context.delete(projectToDelete)
                    //save to coreData
                    do{
                        try self.context.save()
                    }
                    catch{
                        //catch save errors here
                        //I havent found any errors to catch when saving
                    }
                    //refresh TableView
                    self.fetchProjects()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //trailing swipe action complete project
    //Going to have to change this to just change the value of the projects completionStatus
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
        //create action
        let action = UIContextualAction(style: .destructive, title: "Complete Project") { (action, view, completionHandler) in
            //get reference to projecet to remove
            let projectToComplete = self.projects![indexPath.row]
            //before we delete check if there are still Dos in the project and ask the user if they are sure
            if projectToComplete.dos?.count ?? 0 > 0{
                let alert = UIAlertController(title: "Warning", message: "This project still has dos, are you sure you want to complete this project", preferredStyle: .alert)
                let completeAction = UIAlertAction(title: "Complete", style: .default){ (completeAction) in
                    //complete project
                        self.context.delete(projectToComplete)
                        //save to coreData
                        do{
                            try self.context.save()
                        }
                        catch{
                            //catch save errors here
                            //I havent found any errors to catch when saving
                        }
                        //refresh TableView
                        self.fetchProjects()
                    }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(completeAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                }
            else{
                let alert = UIAlertController(title: "Complete", message: "Are you sure you want to complete this project?", preferredStyle: .alert)
                let completeAction = UIAlertAction(title: "Complete", style: .default){ (completeAction) in
                    //complete project
                    self.context.delete(projectToComplete)
                    //save to coreData
                    do{
                        try self.context.save()
                    }
                    catch{
                        //catch save errors here
                        //I havent found any errors to catch when saving
                    }
                    //refresh TableView
                    self.fetchProjects()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(completeAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            }
        //color of the complete action will be blue
        action.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [action])
        }
}
