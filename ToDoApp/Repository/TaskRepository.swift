import CoreData
import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void)
    func addTask(title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void)
    func updateTask(task: TaskEntity, title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void)
    func toggleTaskCompleted(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void)
    func deleteTask(task: TaskEntity, completion: @escaping (Result<Bool, Error>) -> Void)
    func searchTasks(with searchText: String, completion: @escaping ([TaskEntity]) -> Void)
}

class TaskRepository: TaskRepositoryProtocol {
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
    }
    
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var fetchedTasks: [TaskEntity] = []
                    
            context.performAndWait {
                do {
                    fetchedTasks = try context.fetch(request)
                } catch {
                    print("Task fetching error: \(error)")
                }
            }
        }
    }
    
    func addTask(title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let backgroundContext = persistenceController.container.newBackgroundContext()
        
        backgroundContext.perform {
            do {
                let task = TaskEntity(context: backgroundContext)
                task.id = UUID()
                task.title = title
                task.taskDescription = description
                task.isCompleted = false
                task.date = Date()
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateTask(task: TaskEntity, title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let backgroundContext = persistenceController.container.newBackgroundContext()
        let objectID = task.objectID
        
        backgroundContext.perform {
            do {
                guard let taskToUpdate = try backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                    throw NSError(domain: "TaskRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
                }
                
                taskToUpdate.title = title
                taskToUpdate.taskDescription = description
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func toggleTaskCompleted(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let backgroundContext = persistenceController.container.newBackgroundContext()
        let objectID = task.objectID
        
        backgroundContext.perform {
            do {
                guard let taskToUpdate = try backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                    throw NSError(domain: "TaskRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
                }
                
                taskToUpdate.isCompleted.toggle()
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteTask(task: TaskEntity, completion: @escaping (Result<Bool, Error>) -> Void) {
        let backgroundContext = persistenceController.container.newBackgroundContext()
        let objectID = task.objectID
        
        backgroundContext.perform {
            do {
                guard let taskToDelete = try backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                    throw NSError(domain: "TaskRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Задача не найдена"])
                }
                
                backgroundContext.delete(taskToDelete)
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func searchTasks(with searchText: String, completion: @escaping ([TaskEntity]) -> Void) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var fetchedTasks: [TaskEntity] = []
            
            context.performAndWait {
                do {
                    fetchedTasks = try context.fetch(request)
                } catch {
                    print("Task searching error: \(error)")
                }
            }
        }
    }
}
