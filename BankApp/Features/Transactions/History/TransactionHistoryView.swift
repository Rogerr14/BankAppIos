import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = TransactionHistoryViewModel()
    @State private var showsFilters = false
    let accountID: UUID

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(AppColors.muted)
                TextField("Buscar descripción o referencia", text: $viewModel.filters.search)
                    .onChange(of: viewModel.filters.search) { _, _ in viewModel.searchChanged(accountID: accountID, service: container.bankingService) }
                Button { showsFilters = true } label: { Image(systemName: "line.3.horizontal.decrease.circle.fill").font(.title2) }.accessibilityLabel("Filtros")
            }.bankTextField().padding(.horizontal)

            if let error = viewModel.errorMessage { ErrorBanner(message: error).padding(.horizontal) }
            if viewModel.items.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("Sin movimientos", systemImage: "list.bullet.rectangle", description: Text("Prueba cambiando los filtros."))
            } else {
                List {
                    ForEach(groupedDates, id: \.0) { date, items in
                        Section(date.formatted(date: .long, time: .omitted)) {
                            ForEach(items) { item in
                                TransactionRow(description: item.description, date: item.occurredAtUtc, amount: item.amount, isCredit: item.direction == 1, balanceAfter: item.balanceAfter)
                                    .onAppear { if item.id == viewModel.items.last?.id { Task { await viewModel.loadMore(accountID: accountID, service: container.bankingService) } } }
                            }
                        }
                    }
                    if viewModel.isLoading { HStack { Spacer(); ProgressView(); Spacer() } }
                }.listStyle(.plain).refreshable { await viewModel.refresh(accountID: accountID, service: container.bankingService) }
            }
        }
        .navigationTitle("Movimientos").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.brand, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { if viewModel.items.isEmpty { await viewModel.refresh(accountID: accountID, service: container.bankingService) } }
        .sheet(isPresented: $showsFilters) { filtersSheet }
        .fileExporter(isPresented: $viewModel.showsExporter, document: viewModel.exportDocument, contentType: XLSXDocument.readableContentTypes[0], defaultFilename: viewModel.exportFileName) { result in
            if case .failure(let error) = result { viewModel.errorMessage = error.localizedDescription }
        }
    }

    private var groupedDates: [(Date, [TransactionItem])] {
        let calendar = Calendar.current
        return Dictionary(grouping: viewModel.items) { calendar.startOfDay(for: $0.occurredAtUtc) }.sorted { $0.key > $1.key }
    }

    private var filtersSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    BankDateField(title: "Desde", selection: $viewModel.filters.dateFrom)
                    BankDateField(title: "Hasta", selection: $viewModel.filters.dateTo)
                    VStack(alignment: .leading) {
                        Text("Tipo").font(.subheadline.bold())
                        Picker("Tipo", selection: $viewModel.filters.transactionType) {
                            Text("Todos").tag(Int?.none)
                            Text("Depósito").tag(Int?.some(1)); Text("Retiro").tag(Int?.some(2)); Text("Transferencia recibida").tag(Int?.some(3)); Text("Transferencia enviada").tag(Int?.some(4)); Text("Pago de servicio").tag(Int?.some(5)); Text("Comisión").tag(Int?.some(6)); Text("Ajuste").tag(Int?.some(7))
                        }.pickerStyle(.menu).tint(AppColors.brand)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    filterPicker("Dirección", selection: $viewModel.filters.direction, values: [(1, "Créditos"), (2, "Débitos")])
                    filterPicker("Estado", selection: $viewModel.filters.status, values: [(1, "Pendientes"), (2, "Completados"), (3, "Rechazados"), (4, "Reversados")])
                    Button("Aplicar filtros") { showsFilters = false; Task { await viewModel.refresh(accountID: accountID, service: container.bankingService) } }.buttonStyle(PrimaryButtonStyle())
                    Button("Limpiar filtros") { viewModel.filters = .init(); showsFilters = false; Task { await viewModel.refresh(accountID: accountID, service: container.bankingService) } }.foregroundStyle(AppColors.brand)
                    Button { Task { await viewModel.export(accountID: accountID, service: container.bankingService) } } label: { Label("Exportar a Excel", systemImage: "square.and.arrow.down") }.buttonStyle(.bordered).tint(AppColors.brand)
                }.padding(20)
            }.navigationTitle("Filtros").navigationBarTitleDisplayMode(.inline)
        }.presentationDetents([.large])
    }

    private func filterPicker(_ title: String, selection: Binding<Int?>, values: [(Int, String)]) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline.bold())
            Picker(title, selection: selection) {
                Text("Todos").tag(Int?.none)
                ForEach(values, id: \.0) { Text($0.1).tag(Optional($0.0)) }
            }.pickerStyle(.segmented)
        }
    }
}
