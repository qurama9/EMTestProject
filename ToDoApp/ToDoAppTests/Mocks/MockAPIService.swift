import Foundation

class MockAPIService: APIService {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
        super.init()
    }
    
    override func fetchInitialTodos(completion: @escaping (Result<[TodoItem], APIError>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(.success(decoded.todos))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
