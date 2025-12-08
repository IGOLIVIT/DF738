//
//  DataManager.swift
//  DF738
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    // Published properties
    @Published var transactions: [Transaction] = []
    @Published var budgets: [Budget] = []
    @Published var goals: [SavingsGoal] = []
    
    // User Defaults keys
    private let transactionsKey = "transactions"
    private let budgetsKey = "budgets"
    private let goalsKey = "goals"
    
    private init() {
        loadData()
        generateSampleData() // For demo purposes
    }
    
    // MARK: - Transactions
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateBudgetSpending(for: transaction)
        saveTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            recalculateBudgets()
            saveTransactions()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        recalculateBudgets()
        saveTransactions()
    }
    
    func getTransactions(for period: DatePeriod = .all) -> [Transaction] {
        let filtered = transactions.filter { transaction in
            switch period {
            case .today:
                return Calendar.current.isDateInToday(transaction.date)
            case .week:
                return transaction.date >= Date().startOfWeek
            case .month:
                return transaction.date >= Date().startOfMonth
            case .year:
                return transaction.date >= Date().startOfYear
            case .all:
                return true
            }
        }
        return filtered.sorted { $0.date > $1.date }
    }
    
    // MARK: - Budgets
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        recalculateBudgets()
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    private func updateBudgetSpending(for transaction: Transaction) {
        guard transaction.type == .expense else { return }
        
        for index in budgets.indices {
            if budgets[index].category == transaction.category {
                let periodTransactions = getTransactionsForBudgetPeriod(budgets[index])
                budgets[index].spent = periodTransactions
                    .filter { $0.type == .expense }
                    .reduce(0) { $0 + $1.amount }
            }
        }
        saveBudgets()
    }
    
    private func recalculateBudgets() {
        for index in budgets.indices {
            let spent = getTransactionsForBudgetPeriod(budgets[index])
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            budgets[index].spent = spent
        }
        saveBudgets()
    }
    
    private func getTransactionsForBudgetPeriod(_ budget: Budget) -> [Transaction] {
        let now = Date()
        return transactions.filter { transaction in
            transaction.category == budget.category &&
            transaction.type == .expense &&
            {
                switch budget.period {
                case .weekly:
                    return transaction.date >= now.startOfWeek
                case .monthly:
                    return transaction.date >= now.startOfMonth
                case .yearly:
                    return transaction.date >= now.startOfYear
                }
            }()
        }
    }
    
    // MARK: - Goals
    
    func addGoal(_ goal: SavingsGoal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: SavingsGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: SavingsGoal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func addToGoal(_ goal: SavingsGoal, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].currentAmount += amount
            saveGoals()
        }
    }
    
    // MARK: - Analytics
    
    func getFinancialSummary(for period: DatePeriod = .month) -> FinancialSummary {
        let periodTransactions = getTransactions(for: period)
        
        let income = periodTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = periodTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        // Find top spending category
        var categoryTotals: [TransactionCategory: Double] = [:]
        periodTransactions.filter { $0.type == .expense }.forEach { transaction in
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        let topCategory = categoryTotals.max { $0.value < $1.value }?.key
        
        return FinancialSummary(
            totalIncome: income,
            totalExpenses: expenses,
            topCategory: topCategory,
            transactionCount: periodTransactions.count
        )
    }
    
    func getCategoryBreakdown(for period: DatePeriod = .month, type: Transaction.TransactionType = .expense) -> [ChartDataPoint] {
        let periodTransactions = getTransactions(for: period).filter { $0.type == type }
        
        var categoryTotals: [TransactionCategory: Double] = [:]
        periodTransactions.forEach { transaction in
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { category, amount in
            ChartDataPoint(label: category.rawValue, value: amount, color: category.color)
        }.sorted { $0.value > $1.value }
    }
    
    func getMonthlyTrend(months: Int = 6) -> [ChartDataPoint] {
        var monthlyData: [String: (income: Double, expense: Double)] = [:]
        
        for i in 0..<months {
            let date = Calendar.current.date(byAdding: .month, value: -i, to: Date())!
            let monthKey = date.monthYearString
            monthlyData[monthKey] = (0, 0)
        }
        
        transactions.forEach { transaction in
            let monthKey = transaction.date.monthYearString
            if var data = monthlyData[monthKey] {
                if transaction.type == .income {
                    data.income += transaction.amount
                } else {
                    data.expense += transaction.amount
                }
                monthlyData[monthKey] = data
            }
        }
        
        return monthlyData.map { month, data in
            ChartDataPoint(label: month, value: data.income - data.expense, color: data.income > data.expense ? .green : .red)
        }.sorted { $0.label < $1.label }
    }
    
    // MARK: - Persistence
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(encoded, forKey: budgetsKey)
        }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: budgetsKey),
           let decoded = try? JSONDecoder().decode([Budget].self, from: data) {
            budgets = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
            goals = decoded
        }
    }
    
    func resetAllData() {
        transactions.removeAll()
        budgets.removeAll()
        goals.removeAll()
        
        UserDefaults.standard.removeObject(forKey: transactionsKey)
        UserDefaults.standard.removeObject(forKey: budgetsKey)
        UserDefaults.standard.removeObject(forKey: goalsKey)
    }
    
    // MARK: - Sample Data
    
    private func generateSampleData() {
        guard transactions.isEmpty && budgets.isEmpty && goals.isEmpty else { return }
        
        // Sample transactions
        let sampleTransactions = [
            Transaction(amount: 5000, category: .salary, type: .income, note: "Monthly salary", date: Date().addingTimeInterval(-86400 * 5)),
            Transaction(amount: 150, category: .groceries, type: .expense, note: "Weekly shopping", date: Date().addingTimeInterval(-86400 * 4)),
            Transaction(amount: 45, category: .transport, type: .expense, note: "Uber ride", date: Date().addingTimeInterval(-86400 * 3)),
            Transaction(amount: 200, category: .entertainment, type: .expense, note: "Concert tickets", date: Date().addingTimeInterval(-86400 * 2)),
            Transaction(amount: 80, category: .food, type: .expense, note: "Restaurant dinner", date: Date().addingTimeInterval(-86400 * 1)),
            Transaction(amount: 500, category: .freelance, type: .income, note: "Web design project", date: Date())
        ]
        
        transactions = sampleTransactions
        saveTransactions()
        
        // Sample budgets
        let sampleBudgets = [
            Budget(category: .food, limit: 500, period: .monthly),
            Budget(category: .transport, limit: 200, period: .monthly),
            Budget(category: .entertainment, limit: 300, period: .monthly),
            Budget(category: .groceries, limit: 600, period: .monthly)
        ]
        
        budgets = sampleBudgets
        recalculateBudgets()
        
        // Sample goals
        let sampleGoals = [
            SavingsGoal(name: "Emergency Fund", targetAmount: 10000, currentAmount: 3500, deadline: Calendar.current.date(byAdding: .month, value: 12, to: Date()), icon: "💰", color: "blue"),
            SavingsGoal(name: "New Laptop", targetAmount: 2000, currentAmount: 800, deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date()), icon: "💻", color: "purple"),
            SavingsGoal(name: "Vacation", targetAmount: 5000, currentAmount: 1200, deadline: Calendar.current.date(byAdding: .month, value: 8, to: Date()), icon: "✈️", color: "orange")
        ]
        
        goals = sampleGoals
        saveGoals()
    }
}

// MARK: - Date Period Enum

enum DatePeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"
}

// MARK: - Date Extensions

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}

