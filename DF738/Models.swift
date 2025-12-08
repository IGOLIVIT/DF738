//
//  Models.swift
//  DF738
//

import Foundation
import SwiftUI

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: TransactionCategory
    var type: TransactionType
    var note: String
    var date: Date
    var isRecurring: Bool = false
    var recurringPeriod: RecurringPeriod?
    
    enum TransactionType: String, Codable, CaseIterable {
        case income = "Income"
        case expense = "Expense"
    }
    
    enum RecurringPeriod: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
}

// MARK: - Category Model
enum TransactionCategory: String, Codable, CaseIterable {
    // Income categories
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment"
    case other = "Other"
    
    // Expense categories
    case food = "Food & Dining"
    case transport = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bills = "Bills & Utilities"
    case health = "Health & Fitness"
    case education = "Education"
    case travel = "Travel"
    case groceries = "Groceries"
    case housing = "Housing"
    
    var icon: String {
        switch self {
        case .salary: return "💼"
        case .freelance: return "💻"
        case .investment: return "📈"
        case .other: return "💰"
        case .food: return "🍔"
        case .transport: return "🚗"
        case .shopping: return "🛍️"
        case .entertainment: return "🎬"
        case .bills: return "📄"
        case .health: return "💊"
        case .education: return "📚"
        case .travel: return "✈️"
        case .groceries: return "🛒"
        case .housing: return "🏠"
        }
    }
    
    var color: Color {
        switch self {
        case .salary, .freelance, .investment, .other:
            return .green
        case .food:
            return .orange
        case .transport:
            return .blue
        case .shopping:
            return .purple
        case .entertainment:
            return .pink
        case .bills:
            return .red
        case .health:
            return .mint
        case .education:
            return .indigo
        case .travel:
            return .cyan
        case .groceries:
            return .yellow
        case .housing:
            return .brown
        }
    }
    
    var isIncome: Bool {
        switch self {
        case .salary, .freelance, .investment, .other:
            return true
        default:
            return false
        }
    }
}

// MARK: - Budget Model
struct Budget: Identifiable, Codable {
    var id: UUID = UUID()
    var category: TransactionCategory
    var limit: Double
    var period: BudgetPeriod
    var spent: Double = 0
    
    enum BudgetPeriod: String, Codable, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var progress: Double {
        return spent / limit
    }
    
    var remaining: Double {
        return max(0, limit - spent)
    }
    
    var isOverBudget: Bool {
        return spent > limit
    }
}

// MARK: - Savings Goal Model
struct SavingsGoal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double = 0
    var deadline: Date?
    var icon: String
    var color: String
    
    var progress: Double {
        return currentAmount / targetAmount
    }
    
    var remaining: Double {
        return max(0, targetAmount - currentAmount)
    }
    
    var isCompleted: Bool {
        return currentAmount >= targetAmount
    }
    
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
        return days
    }
}

// MARK: - Financial Summary
struct FinancialSummary {
    var totalIncome: Double = 0
    var totalExpenses: Double = 0
    var balance: Double {
        return totalIncome - totalExpenses
    }
    var topCategory: TransactionCategory?
    var transactionCount: Int = 0
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var value: Double
    var color: Color
}


