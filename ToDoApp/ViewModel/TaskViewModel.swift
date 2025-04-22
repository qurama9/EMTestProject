import Foundation
import CoreData
import Combine

class TaskViewModel: ObservableObject {
    
//    MARK: - Properties
    @Published var tasks: [TaskEntity] = []
    @Published var selectedTask: TaskEntity?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let taskRepository: TaskRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(taskRepository: TaskRepositoryProtocol = TaskRepository()) {
        self.taskRepository = taskRepository
        fetchTasks()
        
        // MARK: - Search Binding
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.searchTasks(with: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func searchTasks(with searchText: String) {
        isLoading = true
        taskRepository.searchTasks(with: searchText) { [weak self] tasks in
            self?.tasks = tasks
            self?.isLoading = false
        }
    }
    
//    MARK: - Share
    func shareTask(task: TaskEntity) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        let taskText = """
        Задача: \(task.title ?? "")
        Описание: \(task.taskDescription ?? "")
        Дата: \(formatter.string(from: task.date ?? Date()))
        """
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ShareTask"),
            object: nil,
            userInfo: ["text": taskText])
    }
    
    //    MARK: - CRUD Operations
    func fetchTasks() {
        isLoading = true
        taskRepository.fetchTasks { [weak self] tasks in
            self?.tasks = tasks
            self?.isLoading = false
        }
    }
    
    func addTask(title: String, description: String) {
        isLoading = true
        taskRepository.addTask(title: title, description: description) { [weak self] result in
            defer { self?.isLoading = false }
            
            switch result {
            case .success:
                self?.fetchTasks()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateTask(task: TaskEntity, title: String, description: String) {
        isLoading = true
        taskRepository.updateTask(task: task, title: title, description: description) { [weak self] result in
            defer { self?.isLoading = false }
            
            switch result {
            case .success:
                self?.fetchTasks()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleCompleted(task: TaskEntity) {
        isLoading = true
        taskRepository.toggleTaskCompleted(task: task) { [weak self] result in
            defer { self?.isLoading = false }
            
            switch result {
            case .success:
                self?.fetchTasks()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteTask(task: TaskEntity) {
        isLoading = true
        taskRepository.deleteTask(task: task) { [weak self] result in
            defer { self?.isLoading = false }
            
            switch result {
            case .success:
                self?.fetchTasks()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}
