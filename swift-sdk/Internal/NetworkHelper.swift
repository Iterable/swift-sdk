//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

struct NetworkError: Error {
    let reason: String?
    let data: Data?
    let httpStatusCode: Int?
    let originalError: Error?
    
    init(reason: String? = nil,
         data: Data? = nil,
         httpStatusCode: Int? = nil,
         originalError: Error? = nil) {
        self.reason = reason
        self.data = data
        self.httpStatusCode = httpStatusCode
        self.originalError = originalError
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        reason
    }
}

struct NetworkHelper {
    static let maxRetryCount = 5
    static let retryDelaySeconds = 2
    
    static func getData(fromUrl url: URL, usingSession networkSession: NetworkSessionProtocol) -> Pending<Data, Error> {
        let fulfill = Fulfill<Data, Error>()
        
        networkSession.makeDataRequest(with: url) { data, response, error in
            let result = createDataResultFromNetworkResponse(data: data, response: response, error: error)
            
            switch result {
            case let .success(value):
                DispatchQueue.main.async {
                    fulfill.resolve(with: value)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    fulfill.reject(with: error)
                }
            }
        }
        
        return fulfill
    }
    
    static func sendRequest<T>(_ request: URLRequest,
                               converter: @escaping (Data) throws -> T?,
                               usingSession networkSession: NetworkSessionProtocol) -> Pending<T, NetworkError> {
        
        let requestId = IterableUtil.generateUUID()
        #if NETWORK_DEBUG
        print()
        print("====================================================>")
        print("sending request: \(request)")
        print("requestId: \(requestId)")
        if let headers = request.allHTTPHeaderFields {
            print("headers:")
            print(headers)
        }
        if let body = request.httpBody {
            if let dict = try? JSONSerialization.jsonObject(with: body, options: []) {
                print("request body:")
                print(dict)
            }
        }
        print("====================================================>")
        print()
        #endif
        
        let fulfill = Fulfill<T, NetworkError>()
            
        func sendRequestWithRetries(request: URLRequest, requestId: String, retriesLeft: Int) {
            networkSession.makeRequest(request) { data, response, error in
                let result = createResultFromNetworkResponse(data: data,
                                                             converter: converter,
                                                             response: response,
                                                             error: error)
                switch result {
                    case let .success(value):
                        handleSuccess(requestId: requestId, value: value)
                    case let .failure(error):
                        handleFailure(requestId: requestId, request: request, error: error, retriesLeft: retriesLeft)
                }
            }
        }
        
        func handleSuccess(requestId: String, value: T) {
            #if NETWORK_DEBUG
            print("request with id: \(requestId) successfully sent, response:")
            print(value)
            #endif
            fulfill.resolve(with: value)
        }
        
        func handleFailure(requestId: String, request: URLRequest, error: NetworkError, retriesLeft: Int) {
            if shouldRetry(error: error, retriesLeft: retriesLeft) {
                retryRequest(requestId: requestId, request: request, error: error, retriesLeft: retriesLeft)
            } else {
                #if NETWORK_DEBUG
                print("request with id: \(requestId) errored")
                print(error)
                #endif
                fulfill.reject(with: error)
            }
            
        }
        
        func shouldRetry(error: NetworkError, retriesLeft: Int) -> Bool {
            return error.httpStatusCode ?? 0 >= 500 && retriesLeft > 0
        }
        
        func retryRequest(requestId: String, request: URLRequest, error: NetworkError, retriesLeft: Int) {
            #if NETWORK_DEBUG
            print("retry attempt: \(maxRetryCount-retriesLeft+1) for url: \(request.url?.absoluteString ?? "")")
            print(error)
            #endif
            
            var delay: DispatchTimeInterval = .seconds(0)
            if retriesLeft <= 3 {
                delay = .seconds(retryDelaySeconds)
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                sendRequestWithRetries(request: request, requestId: requestId, retriesLeft: retriesLeft - 1)
            }
        }
        
        sendRequestWithRetries(request: request, requestId: requestId, retriesLeft: maxRetryCount)
        
        return fulfill
    }
    
    private static func createResultFromNetworkResponse<T>(data: Data?,
                                                   converter: (Data) throws -> T?,
                                                   response: URLResponse?,
                                                   error: Error?) -> Result<T, NetworkError> {
        if let error = error {
            return .failure(NetworkError(reason: "\(error.localizedDescription)", data: data, originalError: error))
        }
        
        guard let response = response as? HTTPURLResponse else {
            return .failure(NetworkError(reason: "No response", data: nil))
        }
        
        let httpStatusCode = response.statusCode
        
        if httpStatusCode >= 500 {
            return .failure(NetworkError(reason: "Internal Server Error", data: data, httpStatusCode: httpStatusCode))
        } else if httpStatusCode >= 400 {
            
            if let data = data, 
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let msg = json["msg"] as? String {
                return .failure(NetworkError(reason: msg, data: data, httpStatusCode: httpStatusCode))
            }
            return .failure(NetworkError(reason: "Invalid Request", data: data, httpStatusCode: httpStatusCode))
        } else if httpStatusCode == 200 {
            if let data = data, data.count > 0 {
                return convertData(data: data, converter: converter)
            } else {
                return .failure(NetworkError(reason: "No data received", data: data, httpStatusCode: httpStatusCode))
            }
        } else {
            return .failure(NetworkError(reason: "Received non-200 response: \(httpStatusCode)", data: data, httpStatusCode: httpStatusCode))
        }
    }
    
    private static func convertData<T>(data: Data, converter: (Data) throws -> T?) -> Result<T, NetworkError> {
        do {
            if let responseObj = try converter(data) {
                return .success(responseObj)
            } else {
                return .failure(NetworkError(reason: "Wrong response type", data: data, httpStatusCode: 200))
            }
        } catch {
            var reason = "Could not convert data, error: \(error.localizedDescription)"
            if let stringValue = String(data: data, encoding: .utf8) {
                reason = "Could not convert data: \(stringValue), error: \(error.localizedDescription)"
            }
            return .failure(NetworkError(reason: reason, data: data, httpStatusCode: 200))
        }
    }
    
    private static func createDataResultFromNetworkResponse(data: Data?,
                                                            response _: URLResponse?,
                                                            error: Error?) -> Result<Data, NetworkError> {
        if let error = error {
            return .failure(NetworkError(reason: "\(error.localizedDescription)"))
        }
        
        guard let data = data else {
            return .failure(NetworkError(reason: "No data"))
        }
        
        return .success(data)
    }
}
