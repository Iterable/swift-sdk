//
//  Copyright © 2020 Iterable. All rights reserved.
//

/// These are Iterable specific Request items.
/// They don't have Api endpoint and request endpoint defined yet.

import Foundation

enum IterableRequest {
    case get(GetRequest)
    case post(PostRequest)
    case patch(PatchRequest)
    case delete(DeleteRequest)
}

extension IterableRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case IterableRequest.requestTypeGet:
            let request = try container.decode(GetRequest.self, forKey: .value)
            self = .get(request)
        case IterableRequest.requestTypePatch:
            let request = try container.decode(PatchRequest.self, forKey: .value)
            self = .patch(request)
        case IterableRequest.requestTypePost:
            let request = try container.decode(PostRequest.self, forKey: .value)
            self = .post(request)
        case IterableRequest.requestTypeDelete:
            let request = try container.decode(DeleteRequest.self, forKey: .value)
            self = .delete(request)
        default:
            throw IterableError.general(description: "Unknown request type: \(type)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .get(request):
            try container.encode(IterableRequest.requestTypeGet, forKey: .type)
            try container.encode(request, forKey: .value)
        case let .patch(request):
            try container.encode(IterableRequest.requestTypePatch, forKey: .type)
            try container.encode(request, forKey: .value)
        case let .post(request):
            try container.encode(IterableRequest.requestTypePost, forKey: .type)
            try container.encode(request, forKey: .value)
        case let .delete(request):
            try container.encode(IterableRequest.requestTypeDelete, forKey: .type)
            try container.encode(request, forKey: .value)
        }
    }
    
    func addingBodyField(key: AnyHashable, value: Any) -> IterableRequest {
        if case .post(let postRequest) = self {
            return .post(postRequest.addingBodyField(key: key, value: value))
        } else {
            return self
        }
    }
    
    private static let requestTypeGet = "get"
    private static let requestTypePatch = "patch"
    private static let requestTypePost = "post"
    private static let requestTypeDelete = "delete"
}

struct GetRequest: Codable {
    let path: String
    let args: [String: String]?
}

struct PatchRequest: Codable {
    let path: String
    let args: [String: String]?
}

struct DeleteRequest: Codable {
    let path: String
    let args: [String: String]?
}

struct PostRequest {
    let path: String
    let args: [String: String]?
    let body: [AnyHashable: Any]?
    
    func addingBodyField(key: AnyHashable, value: Any) -> PostRequest {
        var newBody = body ?? [AnyHashable: Any]()
        newBody[key] = value
        return PostRequest(path: path, args: args, body: newBody)
    }
}

extension PostRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case path
        case args
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let path = try container.decode(String.self, forKey: .path)
        let args = try container.decode([String: String]?.self, forKey: .args)
        let body: [AnyHashable: Any]?
        if let bodyData = try container.decode(Data?.self, forKey: .body) {
            body = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [AnyHashable: Any]
        } else {
            body = nil
        }
        self.path = path
        self.args = args
        self.body = body
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(args, forKey: .args)
        var bodyData: Data?
        if let body = self.body, JSONSerialization.isValidJSONObject(body) {
            bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        }
        try container.encode(bodyData, forKey: .body)
    }
}
