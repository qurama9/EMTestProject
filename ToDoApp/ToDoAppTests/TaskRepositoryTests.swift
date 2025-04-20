import XCTest
@testable import ToDoApp

final class TaskRepositoryTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var taskRepository: TaskRepository!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        taskRepository = TaskRepository(persistenceController: persistenceController)
    }
    
    override func tearDown() {
        persistenceController = nil
        taskRepository = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Tasks Test
    func testFetchTasks() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch tasks")
        var fetchedTasks: [TaskEntity] = []
        
        // Create test data
        let context = persistenceController.container.viewContext
        let task = TaskEntity(context: context)
        task.id = UUID()
        task.title = "Test Task"
        task.taskDescription = "Test Description"
        task.isCompleted = false
        task.date = Date()
        
        try? context.save()
        
        // When
        taskRepository.fetchTasks { tasks in
            fetchedTasks = tasks
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.title, "Test Task")
    }
    
    // MARK: - Add Task Test
    func testAddTask() {
        // Given
        let expectation = XCTestExpectation(description: "Add task")
        var result: Result<TaskEntity, Error>?
        
        // When
        taskRepository.addTask(title: "New Task", description: "New Description") { res in
            result = res
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success(let task):
            XCTAssertEqual(task.title, "New Task")
            XCTAssertEqual(task.taskDescription, "New Description")
            XCTAssertFalse(task.isCompleted)
        case .failure(let error):
            XCTFail("Should not fail: \(error)")
        case .none:
            XCTFail("No result")
        }
    }
    
    // MARK: - Update Task Test
    func testUpdateTask() {
        // Given
        let expectation1 = XCTestExpectation(description: "Add task")
        let expectation2 = XCTestExpectation(description: "Update task")
        var addedTask: TaskEntity?
        var updateResult: Result<TaskEntity, Error>?
        
        // First add a task
        taskRepository.addTask(title: "Original Title", description: "Original Description") { result in
            switch result {
            case .success(let task):
                addedTask = task
            case .failure:
                XCTFail("Failed to add task for update test")
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 1.0)
        
        guard let task = addedTask else {
            XCTFail("No task created")
            return
        }
        
        // When
        taskRepository.updateTask(task: task, title: "Updated Title", description: "Updated Description") { result in
            updateResult = result
            expectation2.fulfill()
        }
        
        // Then
        wait(for: [expectation2], timeout: 1.0)
        
        switch updateResult {
        case .success:
            // We need to fetch the task again to see the updates
            let expectation3 = XCTestExpectation(description: "Fetch updated task")
            taskRepository.fetchTasks { tasks in
                let updatedTask = tasks.first { $0.id == task.id }
                XCTAssertNotNil(updatedTask)
                XCTAssertEqual(updatedTask?.title, "Updated Title")
                XCTAssertEqual(updatedTask?.taskDescription, "Updated Description")
                expectation3.fulfill()
            }
            wait(for: [expectation3], timeout: 1.0)
        case .failure(let error):
            XCTFail("Update should not fail: \(error)")
        case .none:
            XCTFail("No update result")
        }
    }
    
    // MARK: - Complete Toggle Task Test
    func testToggleTaskCompleted() {
        // Given
        let expectation1 = XCTestExpectation(description: "Add task")
        let expectation2 = XCTestExpectation(description: "Toggle task")
        var addedTask: TaskEntity?
        var toggleResult: Result<TaskEntity, Error>?
        
        // First add a task (not completed)
        taskRepository.addTask(title: "Toggle Task", description: "Description") { result in
            switch result {
            case .success(let task):
                addedTask = task
            case .failure:
                XCTFail("Failed to add task for toggle test")
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 1.0)
        
        guard let task = addedTask else {
            XCTFail("No task created")
            return
        }
        
        // When
        taskRepository.toggleTaskCompleted(task: task) { result in
            toggleResult = result
            expectation2.fulfill()
        }
        
        // Then
        wait(for: [expectation2], timeout: 1.0)
        
        switch toggleResult {
        case .success:
            // We need to fetch the task again to see the toggle
            let expectation3 = XCTestExpectation(description: "Fetch toggled task")
            taskRepository.fetchTasks { tasks in
                let toggledTask = tasks.first { $0.id == task.id }
                XCTAssertNotNil(toggledTask)
                XCTAssertTrue(toggledTask?.isCompleted ?? false)
                expectation3.fulfill()
            }
            wait(for: [expectation3], timeout: 1.0)
        case .failure(let error):
            XCTFail("Toggle should not fail: \(error)")
        case .none:
            XCTFail("No toggle result")
        }
    }
    
    // MARK: - Delete Task Test
    func testDeleteTask() {
        // Given
        let expectation1 = XCTestExpectation(description: "Add task")
        let expectation2 = XCTestExpectation(description: "Delete task")
        var addedTask: TaskEntity?
        var deleteResult: Result<Bool, Error>?
        
        // First add a task to delete
        taskRepository.addTask(title: "Delete Task", description: "Description") { result in
            switch result {
            case .success(let task):
                addedTask = task
            case .failure:
                XCTFail("Failed to add task for delete test")
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 1.0)
        
        guard let task = addedTask else {
            XCTFail("No task created for delete test")
            return
        }
        
        // When
        taskRepository.deleteTask(task: task) { result in
            deleteResult = result
            expectation2.fulfill()
        }
        
        // Then
        wait(for: [expectation2], timeout: 1.0)
        
        switch deleteResult {
        case .success(let success):
            XCTAssertTrue(success)
            
            // Verify deleted task
            let expectation3 = XCTestExpectation(description: "Verify deletion")
            taskRepository.fetchTasks { tasks in
                let deletedTask = tasks.first { $0.id == task.id }
                XCTAssertNil(deletedTask)
                expectation3.fulfill()
            }
            wait(for: [expectation3], timeout: 1.0)
        case .failure(let error):
            XCTFail("Delete should not fail: \(error)")
        case .none:
            XCTFail("No delete result")
        }
    }
    
    // MARK: - Search Task Test
    func testSearchTasks() {
        // Given
        let context = persistenceController.container.viewContext
        
        // Create multiple test tasks
        let task1 = TaskEntity(context: context)
        task1.id = UUID()
        task1.title = "Shopping List"
        task1.taskDescription = "Buy groceries"
        task1.isCompleted = false
        task1.date = Date()
        
        let task2 = TaskEntity(context: context)
        task2.id = UUID()
        task2.title = "Work Task"
        task2.taskDescription = "Finish project"
        task2.isCompleted = false
        task2.date = Date()
        
        let task3 = TaskEntity(context: context)
        task3.id = UUID()
        task3.title = "Shopping for Electronics"
        task3.taskDescription = "Buy new laptop"
        task3.isCompleted = false
        task3.date = Date()
        
        try? context.save()
        
        // When
        let expectation = XCTestExpectation(description: "Search tasks")
        var searchResults: [TaskEntity] = []
        
        taskRepository.searchTasks(with: "Shopping") { tasks in
            searchResults = tasks
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(searchResults.count, 2)
        XCTAssertTrue(searchResults.contains { $0.title == "Shopping List" })
        XCTAssertTrue(searchResults.contains { $0.title == "Shopping for Electronics" })
        XCTAssertFalse(searchResults.contains { $0.title == "Work Task" })
    }
}
