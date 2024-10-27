//
//  HeartRateViewModel.swift
//  heart-sos Watch App
//
//  Created by Đoàn Khoa on 10/22/24.
//

import Foundation
import HealthKit

class HeartRateViewModel: ObservableObject {
    
    @Published var heartRateModel: HeartRateModel = HeartRateModel(heartRate: 0.0)
    
    private var lowHeartRateTimer: Timer?
    private let lowHeartRateThreshold: Double = 120 // Example threshold
    private let lowHeartRateDuration: TimeInterval = 10 // 10 seconds

    func startHeartRateQuery() {
        HeartRateManager.shared.startHeartRateQuery { [weak self] samples in
            self?.process(samples)
        }
    }
    
    private func process(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let latestSample = samples.last else {
            return
        }

        // Update heart rate on the main thread
        DispatchQueue.main.async {
            let heartRate = latestSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            self.heartRateModel.heartRate = heartRate
            print("Updated Heart Rate: \(heartRate)")
            self.checkHeartRate()
        }
    }
    
    private func checkHeartRate() {
        if heartRateModel.heartRate < lowHeartRateThreshold {
            print("Heart rate below threshold, starting timer")
            startLowHeartRateTimer()
        } else {
            print("Heart rate above threshold, stopping timer")
            stopLowHeartRateTimer()
        }
    }

    private func startLowHeartRateTimer() {
        stopLowHeartRateTimer() // Stop any existing timer

        DispatchQueue.main.async { [self] in
            lowHeartRateTimer = Timer.scheduledTimer(withTimeInterval: lowHeartRateDuration, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                print("Timer finished, calling emergency services")
                self.callEmergencyServices()
            }
        }
    }

    private func stopLowHeartRateTimer() {
        lowHeartRateTimer?.invalidate()
        lowHeartRateTimer = nil
    }

    private func callEmergencyServices() {
        // Code to initiate a call to 911
        print("Calling 911...")
        // Implement the actual call functionality here
    }
}

