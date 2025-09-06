import SwiftUI

struct ContractorView: View {
    @State private var viewModel: ContractorViewModel?
    @EnvironmentObject private var appState: AppStateManager
    
    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                ContractorViewContent(viewModel: viewModel)
            } else {
                ProgressView("Загрузка...")
                    .onAppear {
                        viewModel = ContractorViewModel(appState: appState)
                    }
            }
        }
    }
}

struct ContractorViewContent: View {
    @ObservedObject var viewModel: ContractorViewModel
    @EnvironmentObject private var appState: AppStateManager
    
    var body: some View {
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

struct ContractorRowView: View {
    let contractor: Contractor
    
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

#Preview {
    ContractorView()
        .environmentObject(AppStateManager())
}

