//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Иван on 20.05.2023.
//

import CoreData
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var taskList: [Task] = []
    
    func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func update(_ task: Task, withTitle newTitle: String) {
        task.title = newTitle
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

