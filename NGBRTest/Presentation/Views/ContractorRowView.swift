import SwiftUI

// MARK: - Contractor RowView
struct ContractorRowView: View {
    let contractor: Contractor
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(contractor.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("ID: \(contractor.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            if let fullName = contractor.fullName, !fullName.isEmpty {
                Text(fullName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if !contractor.inn.isEmpty {
                    Text("ИНН: \(contractor.inn)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let kpp = contractor.kpp, !kpp.isEmpty {
                    Text("КПП: \(kpp)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

