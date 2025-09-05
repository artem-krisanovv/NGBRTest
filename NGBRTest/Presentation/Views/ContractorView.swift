import SwiftUI

struct ContractorView: View {
    @StateObject private var viewModel = ContractorViewModel()
    @EnvironmentObject private var appState: AppStateManager
    
    var body: some View {
        NavigationStack {
            LazyVStack {
                Text("Список контрагентов")
                    .font(.title2)
                    .padding()
                
                if viewModel.isLoading && viewModel.contractors.isEmpty {
                    ProgressView("Загрузка контрагентов...")
                } else {
                    List {
                        ForEach(viewModel.contractors) { contractor in
                            ContractorRowView(contractor: contractor) {
                                viewModel.selectedContractor = contractor
                            }
                        }
                        .onDelete { indexSet in
                            guard let index = indexSet.first else { return }
                            Task {
                                await viewModel.deleteContractor(viewModel.contractors[index])
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refreshContractors()
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    Button("Добавить") {
                        Task {
                            viewModel.showingAddContractor = true
                        }
                    }
                    .tint(.appRed)
                    
                    Button("Выйти") {
                        Task {
                            await appState.logout()
                        }
                    }
                    .tint(.black)
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(8)
                .padding()
            }
            .sheet(isPresented: $viewModel.showingAddContractor) {
                ContractorDetailView()
            }
            .sheet(item: $viewModel.selectedContractor) { contractor in
                ContractorDetailView(contractor: contractor)
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("ОК", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            }, message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            })
            .onAppear {
                Task {
                    await viewModel.loadContractors()
                }
            }
        }
    }
}

struct ContractorRowView: View {
    let contractor: Contractor
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(contractor.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let details = contractor.details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let updatedAt = contractor.updatedAt {
                    Text("Обновлено: \(updatedAt, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContractorView()
        .environmentObject(AppStateManager())
}

