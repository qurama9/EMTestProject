import XCTest
@testable import ToDoApp

final class TaskViewModelTests: XCTestCase {
    var viewModel: TaskViewModel!
    var mockRepository: MockTaskRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        viewModel = TaskViewModel(taskRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testFetchTasks() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch tasks")
        let testTask = createTestTaskEntity()
        mockRepository.mockTasks = [testTask]
        
        // When
        viewModel.fetchTasks()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.tasks.count, 1)
            XCTAssertEqual(self.viewModel.tasks.first?.title, "Test Task")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTask() {
        // Given
        let expectation = XCTestExpectation(description: "Add task")
        let testTask = createTestTaskEntity()
        mockRepository.mockAddedTask = testTask
        
        // When
        viewModel.addTask(title: "New Task", description: "New Description")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockRepository.addTaskCalled)
            XCTAssertEqual(self.mockRepository.addedTitle, "New Task")
            XCTAssertEqual(self.mockRepository.addedDescription, "New Description")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateTask() {
        // Given
        let expectation = XCTestExpectation(description: "Update task")
        let testTask = createTestTaskEntity()
        mockRepository.mockUpdatedTask = testTask
        
        // When
        viewModel.updateTask(task: testTask, title: "Updated Task", description: "Updated Description")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockRepository.updateTaskCalled)
            XCTAssertEqual(self.mockRepository.updatedTitle, "Updated Task")
            XCTAssertEqual(self.mockRepository.updatedDescription, "Updated Description")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testToggleCompleted() {
        // Given
        let expectation = XCTestExpectation(description: "Toggle task")
        let testTask = createTestTaskEntity()
        mockRepository.mockToggledTask = testTask
        
        // When
        viewModel.toggleCompleted(task: testTask)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockRepository.toggleTaskCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTask() {
        // Given
        let expectation = XCTestExpectation(description: "Delete task")
        let testTask = createTestTaskEntity()
        mockRepository.mockDeleteSuccess = true
        
        // When
        viewModel.deleteTask(task: testTask)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockRepository.deleteTaskCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchFilter() {
        // Given
        let testTask1 = createTestTaskEntity(title: "Shopping List")
        let testTask2 = createTestTaskEntity(title: "Work Task")
        mockRepository.mockTasks = [testTask1, testTask2]
        
        let expectation = XCTestExpectation(description: "Search tasks")
        
        // When
        viewModel.searchText = "Shopping"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Allow for debounce
            XCTAssertTrue(self.mockRepository.searchCalled)
            XCTAssertEqual(self.mockRepository.searchedText, "Shopping")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Helper method
    private func createTestTaskEntity(title: String = "Test Task") -> TaskEntity {
        let context = PersistenceController.shared.container.viewContext
        let task = TaskEntity(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = "Test Description"
        task.isCompleted = false
        task.date = Date()
        return task
    }
}
