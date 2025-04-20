import CoreData

class InitialDataLoader {
    static let shared = InitialDataLoader()
    private init() {}
    
    func loadInitialDataIfNeeded(context: NSManagedObjectContext) {
        let hasLoadedData = UserDefaults.standard.bool(forKey: "hasLoadedInitialData")
        
        guard !hasLoadedData else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            APIService.shared.fetchInitialTodos { result in
                switch result {
                case .success(let todos):
                    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    
                    backgroundContext.perform {
                        for todo in todos {
                            let task = TaskEntity(context: backgroundContext)
                            task.id = UUID()
                            task.title = todo.todo
                            task.taskDescription = ""
                            task.isCompleted = todo.completed
                            task.date = Date()
                        }
                        
                        do {
                            try backgroundContext.save()
                            
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(true, forKey: "hasLoadedInitialData")
                            }
                        } catch {
                            print("Start data saving error: \(error)")
                        }
                    }
                    
                case .failure(let error):
                    print("Task loading error: \(error.localizedDescription)")
                }
            }
        }
    }
}
