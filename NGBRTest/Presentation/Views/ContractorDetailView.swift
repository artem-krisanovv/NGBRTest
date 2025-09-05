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
                Section("ИНФОРМАЦИЯ О КОНТРАГЕНТЕ") {
                    TextField("Название", text: $viewModel.name)
                    TextField("Описание", text: $viewModel.details)
                    TextField("ИНН", text: $viewModel.inn)
                    TextField("КПП", text: $viewModel.kpp)
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
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("ОК") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: viewModel.isSaved) { _, newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ContractorDetailView()
}
