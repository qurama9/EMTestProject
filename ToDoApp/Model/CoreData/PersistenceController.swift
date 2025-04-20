import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Preview (для SwiftUI Previews)
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // MARK: - Mock-preview
        for i in 0..<3 {
            let newTask = TaskEntity(context: viewContext)
            newTask.id = UUID()
            newTask.title = "Пример \(i + 1)"
            newTask.taskDescription = "Описание задачи \(i + 1)"
            newTask.isCompleted = false
            newTask.date = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Ошибка сохранения preview: \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    // MARK: - Core Data Container
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка инициализации Core Data: \(error), \(error.userInfo)")
            }

            // MARK: - First launch data load
            InitialDataLoader.shared.loadInitialDataIfNeeded(context: self.container.viewContext)
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
