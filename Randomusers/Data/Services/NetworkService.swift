//
//  NetworkService.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

actor NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            case 400...499:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.unknown
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
