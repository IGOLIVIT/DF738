//
//  FinanceSettingsView.swift
//  DF738
//

import SwiftUI

struct FinanceSettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showResetAlert = false
    
    var summary = DataManager.shared.getFinancialSummary(for: .all)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // App Info
                        appInfoSection
                        
                        // Summary Stats
                        summarySection
                        
                        // Actions
                        actionsSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    dataManager.resetAllData()
                }
            } message: {
                Text("Are you sure you want to delete all transactions, budgets, and goals? This action cannot be undone.")
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("ActionPrimary"))
            
            Text("Money Manager")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Track your finances with ease")
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("All Time Statistics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            VStack(spacing: 12) {
                SettingStatRow(icon: "arrow.down.circle.fill", label: "Total Income", value: String(format: "$%.2f", summary.totalIncome), color: .green)
                SettingStatRow(icon: "arrow.up.circle.fill", label: "Total Expenses", value: String(format: "$%.2f", summary.totalExpenses), color: .red)
                SettingStatRow(icon: "equal.circle.fill", label: "Net Balance", value: String(format: "$%.2f", summary.balance), color: summary.balance >= 0 ? .green : .red)
                SettingStatRow(icon: "list.bullet", label: "Total Transactions", value: "\(summary.transactionCount)", color: .blue)
                SettingStatRow(icon: "chart.bar", label: "Active Budgets", value: "\(dataManager.budgets.count)", color: .orange)
                SettingStatRow(icon: "target", label: "Savings Goals", value: "\(dataManager.goals.count)", color: .purple)
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 15) {
            Text("Actions")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset All Data")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red)
                .cornerRadius(12)
            }
        }
    }
}

struct SettingStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(10)
    }
}

#Preview {
    FinanceSettingsView()
}

