//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by admin on 09.06.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    private var numberOfRows: Int = 0
    
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        numberOfRows = tasks.count
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func setupNavigationBar() {
        
        title = "Tasks list"
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do?")
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
        }
            
        self.save(task)

    }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
        
    }
    
    //MARK: - core data managing methods
    //deletes current task
    private func delete(_ task: Task) {
        do {
            managedContext.delete(task)
            try managedContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //Present an alert window to set new task test
    private func showEditAlert(title: String, message: String, index: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }
            
            
            self.tasks[index].name = task
            do {
                try managedContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! Task
        
        task.name = taskName
        
        do {
            try managedContext.save()
            tasks.append(task)
            
            numberOfRows += 1
            print("Inserting to \(numberOfRows - 1) nOfR: \(numberOfRows)")
            self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .automatic)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchData() {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    //MARK: - contextual actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = self.edit(rowIndexPathAt: indexPath)
        let delete = self.delete(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [edit, delete])
        
        return swipe
    }
    
    private func delete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [self] (_, _, _) in
            print("deleting at \(indexPath.row)  nOfR: \(self.numberOfRows)")
            self.delete(self.tasks[indexPath.row])
            self.tasks.remove(at: indexPath.row)
            self.numberOfRows = tasks.count
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return action
    }
    
    private func edit(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { [self] (_, _, _) in
            showEditAlert(title: "Edit task?", message: "Write new text here", index: indexPath.row)
            print("editing at \(indexPath.row)  nOfR: \(self.numberOfRows)")
        }
        return action
    }
    
}

