//
//  TransactionsView.swift
//  DF738
//

import SwiftUI

struct TransactionsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedPeriod: DatePeriod = .month
    @State private var showAddTransaction = false
    @State private var selectedTransaction: Transaction?
    
    var filteredTransactions: [Transaction] {
        dataManager.getTransactions(for: selectedPeriod)
    }
    
    var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Period Selector
                periodSelector
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                
                // Summary Bar
                summaryBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                // Transactions List
                if filteredTransactions.isEmpty {
                    emptyState
                } else {
                    transactionsList
                }
            }
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddTransaction = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("ActionPrimary"))
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DatePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPeriod = period
                        }
                    }) {
                        Text(period.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedPeriod == period ? .white : Color("ElementAccent"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(selectedPeriod == period ? Color("ActionPrimary") : Color("BackgroundSecondary"))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Summary Bar
    
    private var summaryBar: some View {
        let summary = dataManager.getFinancialSummary(for: selectedPeriod)
        
        return HStack(spacing: 20) {
            SummaryItem(
                icon: "arrow.down.circle.fill",
                label: "Income",
                amount: summary.totalIncome,
                color: .green
            )
            
            Divider()
                .frame(height: 40)
            
            SummaryItem(
                icon: "arrow.up.circle.fill",
                label: "Expenses",
                amount: summary.totalExpenses,
                color: .red
            )
            
            Divider()
                .frame(height: 40)
            
            SummaryItem(
                icon: "equal.circle.fill",
                label: "Balance",
                amount: summary.balance,
                color: summary.balance >= 0 ? .green : .red
            )
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
    
    // MARK: - Transactions List
    
    private var transactionsList: some View {
        ScrollView {
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section(header: DateHeader(date: date)) {
                        VStack(spacing: 10) {
                            ForEach(groupedTransactions[date] ?? []) { transaction in
                                TransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        selectedTransaction = transaction
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("ElementAccent").opacity(0.3))
            
            Text("No Transactions")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Start tracking your finances by\nadding your first transaction")
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent").opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: { showAddTransaction = true }) {
                Text("Add Transaction")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color("ActionPrimary"))
                    .cornerRadius(25)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Views

struct SummaryItem: View {
    let icon: String
    let label: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("ElementAccent").opacity(0.7))
            
            Text("$\(amount, specifier: "%.0f")")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct DateHeader: View {
    let date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack {
            Text(dateString)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color("BackgroundPrimary"))
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 15) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(transaction.category.icon)
                    .font(.system(size: 24))
            }
            
            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("ElementAccent"))
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.system(size: 13))
                        .foregroundColor(Color("ElementAccent").opacity(0.6))
                        .lineLimit(1)
                }
                
                if transaction.isRecurring {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                        Text(transaction.recurringPeriod?.rawValue ?? "Recurring")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color("ActionPrimary"))
                }
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.type == .income ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        TransactionsView()
    }
}


