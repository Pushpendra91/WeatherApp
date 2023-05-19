//
//  CombineNetworkService.swift
//  CombineDemoUIKit
//
//  Created by Pushpendra on 11/01/23.
//

import Foundation
import Combine

final class CombineNetworkService {
    static let shared = CombineNetworkService()

    let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func getPublisherForResponse<T: Codable>(request: String) -> AnyPublisher<T, NetworkServiceError> {
        guard let urlRequest = URL(string: request) else {
            return Fail(error: NetworkServiceError.invalidURLError).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap{ (data, response) -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200..<300) ~= httpResponse.statusCode else {
                        throw NetworkServiceError.invalidResponseCode(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError{ error -> NetworkServiceError in
                if let decoadingError = error as? DecodingError {
                    return NetworkServiceError.decoadingError(decoadingError.localizedDescription)
                }
                return NetworkServiceError.genericError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

enum NetworkServiceError: Error {
    case invalidURLError
    case decoadingError(String)
    case genericError(String)
    case invalidResponseCode(Int)

    var errorMessage: String {
        switch self {
        case .invalidURLError:
            return "Invalid URL encountered. Can't proceed with the request"
        case .decoadingError:
            return "Encountered an error while decoding incoming server response. The data couldn’t be read because it isn’t in the correct format."
        case .genericError(let message):
            return message
        case .invalidResponseCode(let responseCode):
            return "Invalid response code encountered from the server. Expected 200, received \(responseCode)"
        }
    }
}
