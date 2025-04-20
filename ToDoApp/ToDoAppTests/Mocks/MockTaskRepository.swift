import Foundation
@testable import ToDoApp

class MockTaskRepository: TaskRepositoryProtocol {
    var mockTasks: [TaskEntity] = []
    var mockAddedTask: TaskEntity?
    var mockUpdatedTask: TaskEntity?
    var mockToggledTask: TaskEntity?
    var mockDeleteSuccess: Bool = false
    
    var addTaskCalled = false
    var updateTaskCalled = false
    var toggleTaskCalled = false
    var deleteTaskCalled = false
    var searchCalled = false
    
    var addedTitle = ""
    var addedDescription = ""
    var updatedTitle = ""
    var updatedDescription = ""
    var searchedText = ""
    
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        completion(mockTasks)
    }
    
    func addTask(title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        addTaskCalled = true
        addedTitle = title
        addedDescription = description
        
        if let task = mockAddedTask {
            completion(.success(task))
        } else {
            completion(.failure(NSError(domain: "Test", code: 1, userInfo: nil)))
        }
    }
    
    func updateTask(task: TaskEntity, title: String, description: String, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        updateTaskCalled = true
        updatedTitle = title
        updatedDescription = description
        
        if let task = mockUpdatedTask {
            completion(.success(task))
        } else {
            completion(.failure(NSError(domain: "Test", code: 1, userInfo: nil)))
        }
    }
    
    func toggleTaskCompleted(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        toggleTaskCalled = true
        
        if let task = mockToggledTask {
            completion(.success(task))
        } else {
            completion(.failure(NSError(domain: "Test", code: 1, userInfo: nil)))
        }
    }
    
    func deleteTask(task: TaskEntity, completion: @escaping (Result<Bool, Error>) -> Void) {
        deleteTaskCalled = true
        
        if mockDeleteSuccess {
            completion(.success(true))
        } else {
            completion(.failure(NSError(domain: "Test", code: 1, userInfo: nil)))
        }
    }
    
    func searchTasks(with searchText: String, completion: @escaping ([TaskEntity]) -> Void) {
        searchCalled = true
        searchedText = searchText
        
        if searchText.isEmpty {
            completion(mockTasks)
        } else {
            let filteredTasks = mockTasks.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
            }
            completion(filteredTasks)
        }
    }
}
