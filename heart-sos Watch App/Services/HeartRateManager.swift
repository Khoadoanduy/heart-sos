//
//  HeartRateManager.swift
//  heart-sos Watch App
//
//  Created by Đoàn Khoa on 10/22/24.
//
import HealthKit

class HeartRateManager {
    
    static let shared = HeartRateManager()
    private let healthStore = HKHealthStore()
    
    // Function to start a heart rate query. It takes a completion handler that returns an optional array of HKSample.
    func startHeartRateQuery(completion: @escaping ([HKSample]?) -> Void) {
        
        // To ensure the heart rate type is valid and If not valid, exit the function early.
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        // Create a predicate to query samples starting from the current date.
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        // Create an anchored object query to get heart rate samples.
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
            completion(samples)
        }
        
        // Set the update handler to be called when new data is available.
        query.updateHandler = { (query, samples, deletedObjects, newAnchor, error) in
            completion(samples)
        }
        
        // Execute the query on the healthStore.
        healthStore.execute(query)
    }
}
