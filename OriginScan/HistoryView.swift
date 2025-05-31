import SwiftUI

struct HistoryView: View {
    @ObservedObject private var historyService = ScanHistoryService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if historyService.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No scan history yet")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(historyService.items) { item in
                            HStack(spacing: 16) {
                                Text(item.flag)
                                    .font(.system(size: 40))
                                    .frame(width: 48, height: 48)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.countryName)
                                        .font(.headline)
                                    if item.localizedCountryName != item.countryName {
                                        Text(item.localizedCountryName)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(item.barcode)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(formattedDate(item.scanDate))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Scan History")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyService.items.isEmpty {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear", systemImage: "trash")
                        }
                    }
                }
            }
            .alert("Clear History", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    historyService.clear()
                }
            } message: {
                Text("Are you sure you want to clear all history?")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
} 