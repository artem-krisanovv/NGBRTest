import SwiftUI

struct ContractorDetailView: View {
    @StateObject private var viewModel: ContractorDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(contractor: Contractor? = nil) {
        _viewModel = StateObject(
            wrappedValue: ContractorDetailViewModel(contractor: contractor)
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о контрагенте") {
                    TextField("Название", text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Описание", text: $viewModel.details, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.saveButtonTitle) {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.name.isEmpty)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Сохранение...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
        .onChange(of: viewModel.isSaved) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    ContractorDetailView()
}
