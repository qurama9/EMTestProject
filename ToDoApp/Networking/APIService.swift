import Foundation

struct TodoResponse: Decodable {
    let todos: [TodoItem]
}

struct TodoItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    func fetchInitialTodos(completion: @escaping (Result<[TodoItem], APIError>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
