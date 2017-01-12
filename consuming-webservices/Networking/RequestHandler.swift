//
//  RequestHandler.swift
//  consuming-webservices
//
//  Created by Stephen Wong on 9/13/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

enum RequestError: Error {
    case requestHandlerNil
    case invalidURL
    case noResponse
    case httpResponse(Int)
    case noData
}

extension RequestError: CustomStringConvertible {
    var description: String {
        switch self {
        case .requestHandlerNil:
            return "No Request Handler"
        case .invalidURL:
            return "Invalid URL"
        case .noResponse:
            return "No Response"
        case .httpResponse(let errorCode):
            return "HTTP Response: \(errorCode)"
        case .noData:
            return "No Data Returned"
        }
    }
}

struct HTTPRequestHandler: RequestHandler {
    var path: String
    var method: NetworkMethod
    var headers: [String : String]?
    var body: Any?
    
    func execute( callback: @escaping (Result<Any>) -> Void) {
        guard
            let url = URL(string: path) else {
                callback(.failure(RequestError.invalidURL))
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        do {
            if let body = body {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    if let response = response as? HTTPURLResponse {
                        callback(.failure(RequestError.httpResponse(response.statusCode)))
                    }
                    else {
                        callback(.failure(error))
                    }
                    
                    return
                }
                guard let data = data else {
                    callback(.failure(RequestError.noData))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let str = String(data: data, encoding: String.Encoding.utf8) {
                        print("Received response: \(str)")
                    }
                    callback(.success(json))
                }
                catch {
                    callback(.failure(error))
                }
            }
            task.resume()
        }
        catch {
            callback(.failure(error))
        }
    }
}
