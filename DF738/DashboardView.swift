//
//  DashboardView.swift
//  DF738
//

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedPeriod: DatePeriod = .month
    @State private var showAddTransaction = false
    
    var summary: FinancialSummary {
        dataManager.getFinancialSummary(for: selectedPeriod)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Period Selector
                        periodSelector
                        
                        // Balance Card
                        balanceCard
                        
                        // Quick Stats
                        quickStatsGrid
                        
                        // Spending by Category Chart
                        categoryChartCard
                        
                        // Recent Transactions
                        recentTransactionsCard
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Dashboard")
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
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DatePeriod.allCases, id: \.self) { period in
                    PeriodButton(period: period, isSelected: selectedPeriod == period) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPeriod = period
                        }
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    // MARK: - Balance Card
    
    private var balanceCard: some View {
        VStack(spacing: 15) {
            Text("Current Balance")
                .font(.system(size: 16))
                .foregroundColor(Color("ElementAccent").opacity(0.7))
            
            Text("$\(summary.balance, specifier: "%.2f")")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(summary.balance >= 0 ? .green : .red)
            
            HStack(spacing: 30) {
                BalanceItem(icon: "arrow.down.circle.fill", label: "Income", amount: summary.totalIncome, color: .green)
                BalanceItem(icon: "arrow.up.circle.fill", label: "Expenses", amount: summary.totalExpenses, color: .red)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [Color("ActionPrimary").opacity(0.8), Color("ActionPrimary")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color("ActionPrimary").opacity(0.3), radius: 10, y: 5)
    }
    
    // MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        HStack(spacing: 15) {
            StatCard(
                icon: "chart.bar.fill",
                title: "Transactions",
                value: "\(summary.transactionCount)",
                color: .blue
            )
            
            StatCard(
                icon: "tag.fill",
                title: "Top Category",
                value: summary.topCategory?.icon ?? "—",
                color: .orange,
                isEmoji: true
            )
        }
    }
    
    // MARK: - Category Chart Card
    
    private var categoryChartCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending by Category")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            let categoryData = dataManager.getCategoryBreakdown(for: selectedPeriod)
            
            if categoryData.isEmpty {
                Text("No expenses yet")
                    .font(.system(size: 14))
                    .foregroundColor(Color("ElementAccent").opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryData.prefix(5)) { data in
                        CategoryRow(data: data, total: summary.totalExpenses)
                    }
                }
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
    
    // MARK: - Recent Transactions Card
    
    private var recentTransactionsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("ElementAccent"))
                
                Spacer()
                
                NavigationLink(destination: TransactionsView()) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ActionPrimary"))
                }
            }
            
            let recentTransactions = dataManager.getTransactions(for: selectedPeriod).prefix(5)
            
            if recentTransactions.isEmpty {
                Text("No transactions yet")
                    .font(.system(size: 14))
                    .foregroundColor(Color("ElementAccent").opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(recentTransactions)) { transaction in
                        TransactionRowCompact(transaction: transaction)
                    }
                }
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
}

// MARK: - Supporting Views

struct PeriodButton: View {
    let period: DatePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color("ElementAccent"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color("ActionPrimary") : Color("BackgroundSecondary"))
                .cornerRadius(20)
        }
    }
}

struct BalanceItem: View {
    let icon: String
    let label: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                Text("$\(amount, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var isEmoji: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            if isEmoji {
                Text(value)
                    .font(.system(size: 32))
            } else {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color("ElementAccent").opacity(0.7))
            
            if !isEmoji {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
}

struct CategoryRow: View {
    let data: ChartDataPoint
    let total: Double
    
    var percentage: Double {
        total > 0 ? (data.value / total) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(data.label)
                    .font(.system(size: 14))
                    .foregroundColor(Color("ElementAccent"))
                
                Spacer()
                
                Text("$\(data.value, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("ElementAccent"))
                
                Text("(\(percentage, specifier: "%.0f")%)")
                    .font(.system(size: 12))
                    .foregroundColor(Color("ElementAccent").opacity(0.6))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("ElementAccent").opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(data.color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct TransactionRowCompact: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(transaction.category.icon)
                    .font(.system(size: 20))
            }
            
            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("ElementAccent"))
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.system(size: 12))
                        .foregroundColor(Color("ElementAccent").opacity(0.6))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.type == .income ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DashboardView()
}


