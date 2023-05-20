//
//  TaskListViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 17.05.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    // MARK: - Private properties
    private let cellID = "cell"
    private let storageManager = StorageManager.shared
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.allowsMultipleSelectionDuringEditing = false
        view.backgroundColor = .white
        setupNavigationBar()
        storageManager.fetchData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storageManager.taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TaskTableViewCell
        let task = storageManager.taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        if isEditing {
            cell.textLabel?.isHidden = true
            cell.textField.isHidden = false
            cell.textField.text = task.title
        } else {
            cell.textLabel?.isHidden = false
            cell.textField.isHidden = true
            cell.textLabel?.text = task.title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = storageManager.taskList[indexPath.row]
            storageManager.delete(task)
            storageManager.fetchData()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.isEnabled = !editing
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.deleteTask(at: indexPath)
            completionHandler(true)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.editTask(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isEditing else { return }
        
        let task = storageManager.taskList[indexPath.row]
        showEditAlert(for: task)
    }
}
// MARK: - Private functions
extension TaskListViewController {
    private func deleteTask(at indexPath: IndexPath) {
        let task = storageManager.taskList[indexPath.row]
        storageManager.delete(task)
        storageManager.fetchData()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func editTask(at indexPath: IndexPath) {
        let task = storageManager.taskList[indexPath.row]
        let alert = UIAlertController(title: "Edit Task", message: "Enter a new title", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else {
                return
            }
            self.storageManager.update(task, withTitle: newTitle)
            self.storageManager.fetchData()
            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alertTitle = isEditing ? "Edit Task" : "New Task"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: isEditing ? "Update Task" : "Save Task", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            storageManager.save(task)
            storageManager.fetchData()
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textText in
            textText.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func showEditAlert(for task: Task) {
        let alert = UIAlertController(title: "Edit Task", message: "Enter a new title", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else {
                return
            }
            storageManager.update(task, withTitle: newTitle)
            storageManager.fetchData()
            tableView.reloadData()
        }
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - SetupUI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
