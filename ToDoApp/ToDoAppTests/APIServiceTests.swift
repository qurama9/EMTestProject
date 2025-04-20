import XCTest
@testable import ToDoApp

final class APIServiceTests: XCTestCase {
    
    func testFetchInitialTodos() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch todos")
        var result: Result<[TodoItem], APIError>?
        
        // When
        APIService.shared.fetchInitialTodos { res in
            result = res
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        
        switch result {
        case .success(let todos):
            XCTAssertFalse(todos.isEmpty, "Should receive todos from API")
        case .failure(let error):
            XCTFail("API call should not fail: \(error)")
        case .none:
            XCTFail("No result")
        }
    }
    
    // MARK: - Mocked API test
    func testFetchInitialTodosMocked() {
        // Given
        let mockJSON = """
        {
            "todos": [
                {
                    "id": 1,
                    "todo": "Test todo",
                    "completed": false
                },
                {
                    "id": 2,
                    "todo": "Another test",
                    "completed": true
                }
            ]
        }
        """
        
        let data = mockJSON.data(using: .utf8)!
        
        let mockURL = URL(string: "https://dummyjson.com/todos")!
        URLProtocol.registerClass(MockURLProtocol.self)
        
        MockURLProtocol.mockData = data
        MockURLProtocol.mockURL = mockURL
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = URLSession(configuration: config)
        
        let apiService = MockAPIService(session: mockSession)
        
        let expectation = XCTestExpectation(description: "Mock API test")
        var result: Result<[TodoItem], APIError>?
        
        // When
        apiService.fetchInitialTodos { res in
            result = res
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success(let todos):
            XCTAssertEqual(todos.count, 2)
            XCTAssertEqual(todos[0].todo, "Test todo")
            XCTAssertEqual(todos[1].todo, "Another test")
            XCTAssertFalse(todos[0].completed)
            XCTAssertTrue(todos[1].completed)
        case .failure(let error):
            XCTFail("Mocked API call should not fail: \(error)")
        case .none:
            XCTFail("No result")
        }
        
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
}

