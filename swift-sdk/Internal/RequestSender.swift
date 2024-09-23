//
//  Copyright © 2021 Iterable. All rights reserved.
//

import Foundation

typealias SendRequestValue = [AnyHashable: Any]

struct SendRequestError: Error {
    let reason: String?
    let data: Data?
    let httpStatusCode: Int?
    let iterableCode: String?
    let originalError: Error?
    
    init(reason: String? = nil,
         data: Data? = nil,
         httpStatusCode: Int? = nil,
         iterableCode: String? = nil,
         originalError: Error? = nil) {
        self.reason = reason
        self.data = data
        self.httpStatusCode = httpStatusCode
        self.iterableCode = iterableCode
        self.originalError = originalError
    }
    
    static func createErroredFuture<T>(reason: String? = nil) -> Pending<T, SendRequestError> {
        Fulfill<T, SendRequestError>(error: SendRequestError(reason: reason))
    }
    
    static func from(error: Error) -> SendRequestError {
        SendRequestError(reason: error.localizedDescription)
    }
    
    static func from(networkError: NetworkError) -> SendRequestError {
        guard let httpStatusCode = networkError.httpStatusCode else {
            return SendRequestError(reason: networkError.reason,
                                    data: networkError.data,
                                    originalError: networkError.originalError)
        }
        
        let json: Any?
        if let data = networkError.data, data.count > 0 {
            do {
                json = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                json = nil
            }
        } else {
            json = nil
        }
        
        if httpStatusCode == 401 {
            var iterableCode: String? = nil
            if let jsonDict = json as? [AnyHashable: Any] {
                iterableCode = jsonDict[JsonKey.Response.iterableCode] as? String
            }
            
            return SendRequestError(reason: networkError.reason,
                                    data: networkError.data,
                                    httpStatusCode: httpStatusCode,
                                    iterableCode: iterableCode,
                                    originalError: networkError.originalError)
        } else if httpStatusCode >= 400 {
            var reason = "Invalid Request"
            if let jsonDict = json as? [AnyHashable: Any], let msgFromDict = jsonDict["msg"] as? String {
                reason = msgFromDict
            } else if httpStatusCode >= 500 {
                reason = "Internal Server Error"
            }
            
            return SendRequestError(reason: reason,
                                    data: networkError.data,
                                    httpStatusCode: httpStatusCode,
                                    originalError: networkError.originalError)
        }
        
        return SendRequestError(reason: networkError.reason,
                                data: networkError.data,
                                httpStatusCode: networkError.httpStatusCode,
                                originalError: networkError.originalError)
    }
}

extension SendRequestError: LocalizedError {
    var errorDescription: String? {
        reason
    }
}

struct RequestSender {
    static func sendRequest<T>(_ request: URLRequest,
                               usingSession networkSession: NetworkSessionProtocol) -> Pending<T, SendRequestError> where T: Decodable {
        let converter: (Data) throws -> T? = { data in
            try JSONDecoder().decode(T.self, from: data)
        }
        
        return NetworkHelper.sendRequest(request,
                                         converter: converter,
                                         usingSession: networkSession)
            .mapFailure(SendRequestError.from(networkError:))
    }

    static func sendRequest(_ request: URLRequest,
                            usingSession networkSession: NetworkSessionProtocol) -> Pending<SendRequestValue, SendRequestError> {
        let converter: (Data) throws -> SendRequestValue? = { data in
            try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
        }
        
        return NetworkHelper.sendRequest(request,
                                         converter: converter,
                                         usingSession: networkSession)
            .mapFailure(SendRequestError.from(networkError:))
    }
}
