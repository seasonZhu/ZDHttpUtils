//
//  AlamofireCodable.swift
//  AlamofireCodable
//
//  Created by season on 2019/2/25.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Codable

extension Request {
    /// Returns a result Codable type that contains the response data as-is.
    ///
    /// - parameter response: The response from the server.
    /// - parameter data:     The data returned from the server.
    /// - parameter error:    The error already encountered if it exists.
    ///
    /// - returns: The result Codable type.
    public static func serializeResponseCodable<T: Codable>(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<T> {
        guard error == nil else { return .failure(error!) }
        
        if let response = response, emptyDataStatusCodes.contains(response.statusCode) {
            do {
                let value = try JSONDecoder().decode(T.self, from: Data())
                return .success(value)
            } catch {
                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
            }
        }
        
        guard let validData = data else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
        }
        
        do {
            let value = try JSONDecoder().decode(T.self, from: validData)
            return .success(value)
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}

extension DataRequest {
    /// Creates a response serializer that returns the associated Coable as-is.
    ///
    /// - returns: A Codable response serializer.
    public static func codableResponseSerializer<T: Codable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseCodable(response: response, data: data, error: error)
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseCodable<T: Codable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.codableResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}

private let emptyDataStatusCodes: Set<Int> = [204, 205]

