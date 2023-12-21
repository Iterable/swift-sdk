//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

/// This struct encapsulates all the data that needs to be sent to Iterable backend.
/// This struct must be `Codable`.
struct IterableAPICallRequest {
    let apiKey: String
    let endpoint: String
    let authToken: String?
    let deviceMetadata: DeviceMetadata
    let iterableRequest: IterableRequest
    
    enum ProcessorType {
        case offline
        case online
    }
    
    func convertToURLRequest(sentAt: Date, processorType: ProcessorType = .online) -> URLRequest? {
        switch iterableRequest {
        case let .get(getRequest):
            return IterableRequestUtil.createGetRequest(forApiEndPoint: endpoint,
                                                        path: getRequest.path,
                                                        headers: createIterableHeaders(sentAt: sentAt,
                                                                                       processorType: processorType),
                                                        args: getRequest.args)
        case let .post(postRequest):
            return IterableRequestUtil.createPostRequest(forApiEndPoint: endpoint,
                                                         path: postRequest.path,
                                                         headers: createIterableHeaders(sentAt: sentAt, processorType: processorType),
                                                         args: postRequest.args,
                                                         body: postRequest.body)
        case let .patch(patchRequest):
            return IterableRequestUtil.createPatchRequest(forApiEndPoint: endpoint,
                                                         path: patchRequest.path,
                                                         headers: createIterableHeaders(sentAt: sentAt, processorType: processorType),
                                                         args: patchRequest.args)
        case let .delete(deleteRequest):
            return IterableRequestUtil.createDeleteRequest(forApiEndPoint: endpoint,
                                                         path: deleteRequest.path,
                                                         headers: createIterableHeaders(sentAt: sentAt,
                                                                                        processorType: processorType),
                                                         args: deleteRequest.args)
        }
    }
    
    func getPath() -> String {
        switch iterableRequest {
        case .get(let request):
            return request.path
        case .post(let request):
            return request.path
        case .patch(let request):
            return request.path
        case .delete(let request):
            return request.path
        }
    }
    
    func addingCreatedAt(_ createdAt: Date) -> IterableAPICallRequest {
        addingBodyField(key: JsonKey.Body.createdAt,
                        value: IterableUtil.secondsFromEpoch(for: createdAt))
    }
    
    private func addingBodyField(key: AnyHashable, value: Any) -> IterableAPICallRequest {
        IterableAPICallRequest(apiKey: apiKey,
                               endpoint: endpoint,
                               authToken: authToken,
                               deviceMetadata: deviceMetadata,
                               iterableRequest: iterableRequest.addingBodyField(key: key, value: value))
    }
    
    private func createIterableHeaders(sentAt: Date, processorType: ProcessorType) -> [String: String] {
        var headers = [JsonKey.contentType: JsonValue.applicationJson,
                       JsonKey.Header.sdkPlatform: JsonValue.iOS,
                       JsonKey.Header.sdkVersion: IterableAPI.sdkVersion,
                       JsonKey.Header.apiKey: apiKey,
                       JsonKey.Header.sentAt: Self.format(sentAt: sentAt),
                       JsonKey.Header.requestProcessor: Self.name(for: processorType)
        ]
        
        if let authToken = authToken {
            headers[JsonKey.Header.authorization] = "Bearer \(authToken)"
        }
        
        return headers
    }
    
    private static func format(sentAt: Date) -> String {
        return "\(IterableUtil.secondsFromEpoch(for: sentAt))"
    }
    
    private static func name(for processorType: ProcessorType) -> String {
        switch processorType {
        case .online:
            return Const.ProcessorTypeName.online
        case .offline:
            return Const.ProcessorTypeName.offline
        }
    }
}

extension IterableAPICallRequest: Codable {}
