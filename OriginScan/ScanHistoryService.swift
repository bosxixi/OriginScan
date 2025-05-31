import Foundation

struct ScanHistoryItem: Identifiable, Codable {
    let id: UUID
    let countryCode: String
    let countryName: String
    let flag: String
    let barcode: String
    let scanDate: Date
    
    init(countryCode: String, countryName: String, flag: String, barcode: String, scanDate: Date = Date()) {
        self.id = UUID()
        self.countryCode = countryCode
        self.countryName = countryName
        self.flag = flag
        self.barcode = barcode
        self.scanDate = scanDate
    }
}

class ScanHistoryService: ObservableObject {
    static let shared = ScanHistoryService()
    private let userDefaultsKey = "scanHistoryItems"
    
    @Published private(set) var items: [ScanHistoryItem] = []
    
    private init() {
        load()
    }
    
    func add(item: ScanHistoryItem) {
        items.insert(item, at: 0)
        save()
    }
    
    func clear() {
        items.removeAll()
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([ScanHistoryItem].self, from: data) {
            items = decoded
        }
    }
} 