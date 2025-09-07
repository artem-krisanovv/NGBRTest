import SwiftUI

// MARK: - Contractor Detail View
struct ContractorDetailView: View {
    @ObservedObject private var viewModel: ContractorDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    init(viewModel: ContractorDetailViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
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
                    Button(viewModel.saveButtonTitle) { [weak viewModel] in
                        Task {
                            await viewModel?.save()
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.name.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("ОК") { [weak viewModel] in
                    viewModel?.errorMessage = nil
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
    ContractorDetailViewFactory.create(serviceContainer: ServiceContainer())
}
