import SwiftUI
import SwiftData
import Charts

enum RecapFilter: String, CaseIterable {
    case daily = "Daily"
    case monthly = "Monthly"
}

struct RecapPage: View {
    @State private var showingAddSheet = false
    @State private var selectedFilter: RecapFilter = .daily
    @State private var selectedDate = Date()
    @State private var selectedCategory: TransactionType? = nil
    @State private var showActionSheet = false
    @State private var showModal = false
    @State private var modalType: TransactionType? = nil
    @State private var selectedTransaction: Transaction? = nil
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.calendar) private var calendar
    @Query private var allTransactions: [Transaction]
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        return allTransactions.filter { txn in
            if let category = selectedCategory, txn.type != category && selectedFilter == .daily {
                return false
            }
            
            switch selectedFilter {
            case .daily:
                return calendar.isDate(txn.date, inSameDayAs: selectedDate)
            case .monthly:
                let txnComp = calendar.dateComponents([.year, .month], from: txn.date)
                let selectedComp = calendar.dateComponents([.year, .month], from: selectedDate)
                return txnComp.year == selectedComp.year && txnComp.month == selectedComp.month
            }
        }
    }
    
    private var groupedMonthlyTransactions: [GroupedTransaction] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) { txn in
            calendar.startOfDay(for: txn.date)
        }
        
        return grouped.map {(date, txns) in
            let total = txns.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
            return GroupedTransaction(date: date, totalAmount: total)
        }.sorted { $0.date < $1.date }
    }
    
    private var filteredMonthlyTransactions: [GroupedTransaction] {
        let result = groupedMonthlyTransactions
        
        switch selectedCategory {
        case .income:
            return result.filter { $0.totalAmount > 0}
        case .expense:
            return result.filter { $0.totalAmount < 0}
        default:
            return result
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack (alignment: .leading) {
                Picker("Recap Filter", selection: $selectedFilter) {
                    ForEach(RecapFilter.allCases, id:\.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .padding(.bottom, 36)
                
                ChartView(transactions: allTransactions, filter: selectedFilter, selectedDate: $selectedDate)
                if selectedFilter == .daily {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.horizontal)
                } else {
                    MonthYearPicker(selectedDate: $selectedDate)
                        .padding(.horizontal)
                }
                
                
                HStack {
                    SummaryCard(title: selectedFilter == .daily ? "Income" : "Profit", amount: calculateIncome(), textColor: .green, selectedColor: .green, imageName: "chart.line.uptrend.xyaxis", selected: selectedCategory == .income).onTapGesture {
                        selectedCategory = selectedCategory == .income ? nil : .income
                    }
                    SummaryCard(title: selectedFilter == .daily ? "Expense" : "Loss", amount: calculateExpense(), textColor: .red, selectedColor: .red, imageName: "chart.line.downtrend.xyaxis", selected: selectedCategory == .expense).onTapGesture {
                        selectedCategory = selectedCategory == .expense ? nil : .expense
                    }
                    SummaryCard(title: "Net Total", amount: calculateTotal(), textColor: .blue, selectedColor: .blue, imageName: "circle.grid.3x3.fill", selected: selectedCategory == nil).onTapGesture {
                        selectedCategory = nil
                    }
                }
                .padding(.horizontal)
                
                if filteredTransactions.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Transactions", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start adding expenses to see your list.")
                    })
                    .offset(y: -60)
                    .background(
                        Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark ? .black : .systemGray6
                        })
                    )
                } else {
                    if selectedFilter == .daily {
                        List(filteredTransactions) { txn in
                            DailyTransactionRow(transaction: txn)
                                .onTapGesture {
                                    selectedTransaction = txn
                                }
                        }
                    } else {
                        List(filteredMonthlyTransactions) { group in
                            MonthlyTransactionRow(transaction: group)
                        }
                    }
                }
            }
            
            Button(action: {showActionSheet = true}) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.accentColor)
                    .shadow(radius: 4)
            }
            .padding()
            .confirmationDialog("Add Transaction", isPresented: $showActionSheet) {
                Button("Add Income") {
                    modalType = .income
                    showModal = true
                }
                
                Button("Add Expense") {
                    modalType = .expense
                    showModal = true
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .userActivity("com.hikaru.CanteenMateV2.addincome") { activity in
            activity.title = "Add Income"
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.hikaru.CanteenMateV2.addincome")
            activity.keywords = Set(["CanteenMate", "Income", "Add Income", "Canteen", "Transaction"])
            activity.requiredUserInfoKeys = []
            activity.becomeCurrent()
        }
        .onContinueUserActivity("com.hikaru.CanteenMateV2.addincome") { _ in
            showModal = true
            modalType = .income
        }
        .userActivity("com.hikaru.CanteenMateV2.addexpense") { activity in
            activity.title = "Add Expense"
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.hikaru.CanteenMateV2.addexpense")
            activity.keywords = Set(["CanteenMate", "Expense", "Add Expense", "Canteen", "Transaction"])
            activity.requiredUserInfoKeys = []
            activity.becomeCurrent()
        }
        .onContinueUserActivity("com.hikaru.CanteenMateV2.addexpense") { _ in
            showModal = true
            modalType = .expense
        }
        .background(Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black : .systemGray6
        }))
        .sheet(isPresented: $showModal) {
            if let type = modalType {
                AddTransactionView(category: type)
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            EditTransactionView(transaction: transaction)
        }
    }
    
    func filterDaily(transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let today = Date()
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: today)
        }
    }
    
    func filterMonthly(transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let today = Date()
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: today, toGranularity: .month)
        }
    }
    
    private func calculateIncome() -> Int {
        if selectedFilter == .monthly {
            return groupedMonthlyTransactions
                .filter{$0.totalAmount > 0}
                .map{$0.totalAmount}
                .reduce(0, +)
        }
        return allTransactions
            .filter { $0.type == .income }
            .filter { txn in calendar.isDate(txn.date, inSameDayAs: selectedDate)}
            .map { $0.amount }.reduce(0, +)
    }
    
    private func calculateExpense() -> Int {
        if selectedFilter == .monthly {
            return groupedMonthlyTransactions
                .filter{$0.totalAmount < 0}
                .map{$0.totalAmount}
                .reduce(0, +)
        }
        return allTransactions
            .filter { $0.type == .expense }
            .filter { txn in calendar.isDate(txn.date, inSameDayAs: selectedDate)}
            .map { $0.amount }.reduce(0, +)
    }
    
    private func calculateTotal() -> Int {
        if selectedFilter == .monthly {
            return calculateIncome() + calculateExpense()
        }
        return calculateIncome() - calculateExpense()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Transaction.self, Menu.self, configurations: config)
    
    let context = modelContainer.mainContext
    let calendar = Calendar.current
    let now = Date()

    let sampleDates = [
        now,
        calendar.date(byAdding: .day, value: -1, to: now)!,
        calendar.date(byAdding: .day, value: -2, to: now)!,
        calendar.date(byAdding: .day, value: -7, to: now)!,
        calendar.date(byAdding: .day, value: -14, to: now)!
    ]

    let dummyData = [
        Transaction(name: "Salary", date: sampleDates[0], amount: 50000, type: .income, count: 1),
        Transaction(name: "Lunch", date: sampleDates[1], amount: 25000, type: .expense, count: 1),
        Transaction(name: "Internet", date: sampleDates[0], amount: 150000, type: .expense, count: 1),
        Transaction(name: "Internet", date: sampleDates[0], amount: 150000, type: .expense, count: 1),
        Transaction(name: "Side Job", date: sampleDates[0], amount: 1000000, type: .income, count: 1),
        Transaction(name: "Groceries", date: sampleDates[0], amount: 200000, type: .expense, count: 1),
    ]
    
    let dummyMenu = [
        Menu(name: "Bakso", price: 15000),
        Menu(name: "Es Jeruk", price: 10000)
    ]

    dummyData.forEach { context.insert($0) }
    dummyMenu.forEach { context.insert($0) }

    return RecapPage()
        .modelContainer(modelContainer)
}
