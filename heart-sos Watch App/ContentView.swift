// heart-sos/ContentView.swift
import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var heartRate: Double = 0
    @State private var respiratoryRate: Double = 0
    private let healthStore = HKHealthStore()
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Text("Heart Rate: \(heartRate)")
            Text("Respiratory Rate: \(respiratoryRate)")
        }
        .onAppear {
            requestHealthKitPermissions()
            startHeartRateObserver()
//            startFetchingHealthData()
//            fetchHealthData()
        }
        .onChange(of: heartRate) {
            checkHealthData()
        }
        .onChange(of: respiratoryRate) {
            checkHealthData()
        }
        
    }
    private func startFetchingHealthData() {
        // Start a timer to fetch health data every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            fetchHealthData()
            printHeartRate()
        }
    }
    private func stopFetchingHealthData() {
        // Invalidate the timer when the view disappears
        timer?.invalidate()
        timer = nil
    }
    
    private func requestHealthKitPermissions() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
              let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) else {
            return
        }
        
        // Declare typesToShare as Set<HKSampleType>
        let typesToShare: Set<HKSampleType> = [heartRateType, respiratoryRateType]
        // Declare typesToRead as Set<HKObjectType>
        let typesToRead: Set<HKObjectType> = [heartRateType, respiratoryRateType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted.")
                startFetchingHealthData()
                fetchHealthData()
            } else {
                print("HealthKit authorization denied: \(String(describing: error))")
            }
        }
    }
    
    private func fetchHealthData() {
        fetchHeartRate()
        fetchRespiratoryRate()
    }
    
    private func fetchHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: nil) { _, results, error in
            guard let results = results, let sample = results.first as? HKQuantitySample else {
                print("Failed to fetch heart rate: \(String(describing: error))")
                return
            }
            heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("Current Heart Rate: \(heartRate)")
        }
        healthStore.execute(query)
    }
    
    private func fetchRespiratoryRate() {
        let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        let query = HKSampleQuery(sampleType: respiratoryRateType, predicate: nil, limit: 1, sortDescriptors: nil) { _, results, error in
            guard let results = results, let sample = results.first as? HKQuantitySample else {
                print("Failed to fetch respiratory rate: \(String(describing: error))")
                return
            }
            respiratoryRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        }
        healthStore.execute(query)
    }
    
    private func checkHealthData() {
        if heartRate <= 0 || respiratoryRate <= 0 {
            callEmergencyServices()
        }
    }
    
    private func callEmergencyServices() {
        if let url = URL(string: "tel://911") {
            WKExtension.shared().openSystemURL(url)
        }
    }
    private func printHeartRate() { // {{ edit_3 }} - New function to print heart rate
            print("Heart Rate: \(heartRate)")
    }
    
    private func startHeartRateObserver() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type is not available.")
            return
        }
        
        // Create an observer query to listen for heart rate changes
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [self] _, completionHandler, error in
            if let error = error {
                print("Error setting up observer query: \(error.localizedDescription)")
                return
            }
            
            // Fetch the latest heart rate data
            fetchHeartRate()
            
            // Call the completion handler to let HealthKit know that the query has been processed
            completionHandler()
        }
        
        // Execute the observer query
        healthStore.execute(observerQuery)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple Watch Series 6")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
