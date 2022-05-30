//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

class IterableTaskScheduler {
    init(persistenceContextProvider: IterablePersistenceContextProvider,
         notificationCenter: NotificationCenterProtocol = NotificationCenter.default,
         healthMonitor: HealthMonitor,
         dateProvider: DateProviderProtocol = SystemDateProvider()) {
        self.persistenceContextProvider = persistenceContextProvider
        self.notificationCenter = notificationCenter
        self.healthMonitor = healthMonitor
        self.dateProvider = dateProvider
    }
    
    func schedule(apiCallRequest: IterableAPICallRequest,
                  context: IterableTaskContext = IterableTaskContext(blocking: true),
                  scheduledAt: Date? = nil) -> Result<String, IterableTaskError> {
        ITBInfo()
        let taskId = IterableUtil.generateUUID()
        do {
            let data = try JSONEncoder().encode(apiCallRequest)
            
            try persistenceContext.performAndWait {
                try persistenceContext.create(task: IterableTask(id: taskId,
                                                                 name: apiCallRequest.getPath(),
                                                                 type: .apiCall,
                                                                 scheduledAt: scheduledAt ?? dateProvider.currentDate,
                                                                 data: data,
                                                                 requestedAt: dateProvider.currentDate))
                try persistenceContext.save()
                
            }
            notificationCenter.post(name: .iterableTaskScheduled, object: self, userInfo: nil)
        } catch let error {
            healthMonitor.onScheduleError(apiCallRequest: apiCallRequest)
            return Result.failure(IterableTaskError.general("schedule taskId: \(taskId) failed with error: \(error.localizedDescription)"))
        }
        return Result.success(taskId)
    }
    
    func deleteAllTasks() {
        ITBInfo()
        do {
            try persistenceContext.performAndWait {
                try persistenceContext.deleteAllTasks()
            }
        } catch let error {
            ITBError("deleteAllTasks: \(error.localizedDescription)")
            healthMonitor.onDeleteAllTasksError()
        }
    }
    
    private let persistenceContextProvider: IterablePersistenceContextProvider
    private let notificationCenter: NotificationCenterProtocol
    private let healthMonitor: HealthMonitor
    private let dateProvider: DateProviderProtocol

    private lazy var persistenceContext: IterablePersistenceContext = {
        return persistenceContextProvider.newBackgroundContext()
    }()
}
