//
//  Copyright © 2023 Iterable. All rights reserved.
//

import Foundation

struct EmbeddedMessagingProcessor {
    init(currentMessages: [Int: [IterableEmbeddedMessage]], fetchedMessages: [Int: [IterableEmbeddedMessage]]) {
        self.currentMessages = currentMessages
        self.fetchedMessages = fetchedMessages
    }

    func processedMessagesList() -> [Int: [IterableEmbeddedMessage]] {
        return fetchedMessages
    }
    
    func processedMessageIdList() -> [String] {
        var fetchedMessageIds: [String] = []
        
        for (_, messages) in fetchedMessages {
            for message in messages {
                fetchedMessageIds.append(message.metadata.messageId)
            }
        }
        
        return fetchedMessageIds
    }

    func newlyRetrievedMessages() -> [Int: [IterableEmbeddedMessage]] {
        var newMessages: [Int: [IterableEmbeddedMessage]] = [:]
        
        for (placementId, fetchedMessagesList) in fetchedMessages {
            let currentMessageIds = currentMessages[placementId]?.map { $0.metadata.messageId } ?? []
            let newFetchedMessages = fetchedMessagesList.filter { !currentMessageIds.contains($0.metadata.messageId) }
            
            if !newFetchedMessages.isEmpty {
                newMessages[placementId] = newFetchedMessages
            }
        }
        
        return newMessages
    }

    func newlyRemovedMessageIds() -> [Int: [String]] {
        var removedMessageIds: [Int: [String]] = [:]

        for (placementId, messages) in currentMessages {
            let currentMessageIds = messages.map { $0.metadata.messageId }
            let fetchedMessageIds = fetchedMessages[placementId]?.map { $0.metadata.messageId } ?? []
            
            let removedIds = currentMessageIds.filter { !fetchedMessageIds.contains($0) }
            if !removedIds.isEmpty {
                removedMessageIds[placementId] = removedIds
            }
        }

        return removedMessageIds
    }

    // MARK: - PRIVATE/INTERNAL

    private let currentMessages: [Int: [IterableEmbeddedMessage]]
    private let fetchedMessages: [Int: [IterableEmbeddedMessage]]
}
