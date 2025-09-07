import SwiftUI

// MARK: - Contractor View
struct ContractorView: View {
    @ObservedObject private var viewModel: ContractorViewModel
    @EnvironmentObject private var appState: AppStateManager
    @EnvironmentObject private var serviceContainer: ServiceContainer
    
    // MARK: - Init
    init(viewModel: ContractorViewModel) {
        self.viewModel = viewModel
    }
    
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
                            Button {
                                viewModel.selectedContractor = contractor
                            } label: {
                                ContractorRowView(contractor: contractor)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { [weak viewModel] indexSet in
                            guard let index = indexSet.first, let viewModel = viewModel else { return }
                            Task {
                                await viewModel.deleteContractor(viewModel.contractors[index])
                            }
                        }
                    }
                    .refreshable { [weak viewModel] in
                        await viewModel?.refreshContractors()
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Добавить") {
                        Task { [weak viewModel] in
                            viewModel?.showingAddContractor = true
                        }
                    }
                    .tint(.appRed)
                    
                    Button("Выйти") {
                        Task { [weak appState] in
                            await appState?.logout()
                        }
                    }
                    .tint(.black)
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(8)
                .padding()
            }
            .sheet(isPresented: $viewModel.showingAddContractor) {
                ContractorDetailViewFactory.create(serviceContainer: serviceContainer)
                    .onDisappear {
                        Task { [weak viewModel] in
                            await viewModel?.loadContractors()
                        }
                    }
            }
            .sheet(item: $viewModel.selectedContractor) { (contractor: Contractor) in
                ContractorDetailViewFactory.create(contractor: contractor, serviceContainer: serviceContainer)
                    .onDisappear {
                        Task { [weak viewModel] in
                            await viewModel?.loadContractors()
                        }
                    }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("ОК", role: .cancel) { [weak viewModel] in
                    viewModel?.errorMessage = nil
                }
            }, message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            })
            .onAppear { [weak viewModel] in
                viewModel?.updateAppState(appState)
                Task {
                    await viewModel?.loadContractors()
                }
            }
        }
    }
}

#Preview {
    let container = ServiceContainer()
    let appState = AppStateManager(tokenManager: container.tokenManager)
    return ContractorViewFactory.create(serviceContainer: container, appState: appState)
        .environmentObject(appState)
        .environmentObject(container)
}

