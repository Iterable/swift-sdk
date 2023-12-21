//
//  Copyright © 2018 Iterable. All rights reserved.
//

/// This is a utility class which takes an apiEndpoint, path, header, args etc to create URLRequest objects.
/// The methods should be generic and not specific to Iterable.

import Foundation

struct IterableRequestUtil {
    static func createGetRequest(forApiEndPoint apiEndPoint: String,
                                 path: String,
                                 headers: [String: String]? = nil,
                                 args: [String: String]? = nil) -> URLRequest? {
        guard let url = getUrlComponents(forApiEndPoint: apiEndPoint, path: path, args: args)?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        addHeaders(headers: headers, toRequest: &request)
        request.httpMethod = Const.Http.GET
        
        return request
    }
    
    static func createPatchRequest(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil) -> URLRequest? {
        createPatchRequest1(forApiEndPoint: apiEndPoint,
                          path: path,
                          headers: headers,
                          args: args)
    }
    
    static func createDeleteRequest(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil) -> URLRequest? {
        createDeleteRequest1(forApiEndPoint: apiEndPoint,
                          path: path,
                          headers: headers,
                          args: args)
    }
    
    static func createPostRequest(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil,
                                  body: [AnyHashable: Any]? = nil) -> URLRequest? {
        createPostRequest(forApiEndPoint: apiEndPoint,
                          path: path,
                          headers: headers,
                          args: args,
                          body: dictToJsonData(body))
    }
    
    static func createPostRequest<T: Encodable>(forApiEndPoint apiEndPoint: String,
                                                path: String,
                                                headers: [String: String]? = nil,
                                                args: [String: String]? = nil,
                                                body: T) -> URLRequest? {
        createPostRequest(forApiEndPoint: apiEndPoint,
                          path: path,
                          headers: headers,
                          args: args,
                          body: try? JSONEncoder().encode(body))
    }
    
    static func createPostRequest(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil,
                                  body: Data? = nil) -> URLRequest? {
        guard let url = getUrlComponents(forApiEndPoint: apiEndPoint, path: path, args: args)?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        addHeaders(headers: headers, toRequest: &request)
        request.httpMethod = Const.Http.POST
        request.httpBody = body
        
        return request
    }
    
    static func createPatchRequest1(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil) -> URLRequest? {
        guard let url = getUrlComponents(forApiEndPoint: apiEndPoint, path: path, args: args)?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        addHeaders(headers: headers, toRequest: &request)
        request.httpMethod = Const.Http.PATCH
        
        return request
    }
    
    static func createDeleteRequest1(forApiEndPoint apiEndPoint: String,
                                  path: String,
                                  headers: [String: String]? = nil,
                                  args: [String: String]? = nil,
                                  body: Data? = nil) -> URLRequest? {
        guard let url = getUrlComponents(forApiEndPoint: apiEndPoint, path: path, args: args)?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        addHeaders(headers: headers, toRequest: &request)
        request.httpMethod = Const.Http.DELETE
        
        return request
    }
    
    static func dictToJsonData(_ dict: [AnyHashable: Any]?) -> Data? {
        guard let dict = dict else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    static func pathCombine(paths: [String]) -> String {
        paths.reduce("", pathCombine)
    }
    
    private static func addHeaders(headers: [String: String]?, toRequest request: inout URLRequest) {
        if let headers = headers {
            headers.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
    }
    
    private static func getUrlComponents(forApiEndPoint apiEndPoint: String, path: String, args: [String: String]? = nil) -> URLComponents? {
        let endPointCombined = pathCombine(path1: apiEndPoint, path2: path)
        
        guard var components = URLComponents(string: "\(endPointCombined)") else {
            return nil
        }
        
        if let args = args {
            components.queryItems = args.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        return components
    }
    
    private static func pathCombine(path1: String, path2: String) -> String {
        var result = path1
        
        if result.hasSuffix("/") {
            result.removeLast()
        }
        
        // result has no ending slashes, add one if needed
        if !result.isEmpty, !path2.isEmpty, !path2.hasPrefix("/") {
            result.append("/")
        }
        
        result.append(path2)
        
        return result
    }
}
