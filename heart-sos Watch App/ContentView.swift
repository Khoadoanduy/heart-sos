// heart-sos/ContentView.swift
import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var heartRate: Double = 0
    @State private var respiratoryRate: Double = 0
    private let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            Text("Heart Rate: \(heartRate)")
            Text("Respiratory Rate: \(respiratoryRate)")
        }
        .onAppear {
            requestHealthKitPermissions()
            fetchHealthData()
        }
        .onChange(of: heartRate) {
            checkHealthData()
        }
        .onChange(of: respiratoryRate) {
            checkHealthData()
        }
        
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple Watch Series 6")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
