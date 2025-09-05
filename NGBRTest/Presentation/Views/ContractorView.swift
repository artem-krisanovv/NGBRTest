import SwiftUI

struct ContractorView: View {
    @StateObject private var viewModel = ContractorViewModel()
    @EnvironmentObject private var appState: AppStateManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Список контрагентов")
                    .font(.title2)
                    .padding()
                
                if viewModel.isLoading && viewModel.contractors.isEmpty {
                    VStack {
                        ProgressView("Загрузка контрагентов...")
                            .scaleEffect(1.2)
                        Text("Подождите, загружаем данные...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.contractors.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Контрагенты не найдены")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Нажмите кнопку \"Добавить\" чтобы создать первого контрагента")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .onDisappear {
                        Task {
                            await viewModel.loadContractors()
                        }
                    }
            }
            .sheet(item: $viewModel.selectedContractor) { contractor in
                ContractorDetailView(contractor: contractor)
                    .onDisappear {
                        Task {
                            await viewModel.loadContractors()
                        }
                    }
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
                
                if let details = contractor.fullName, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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

