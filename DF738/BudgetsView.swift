//
//  BudgetsView.swift
//  DF738
//

import SwiftUI

struct BudgetsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showAddBudget = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                if dataManager.budgets.isEmpty {
                    emptyState
                } else {
                    budgetsList
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("ActionPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView()
            }
        }
    }
    
    private var budgetsList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(dataManager.budgets) { budget in
                    BudgetCard(budget: budget)
                }
            }
            .padding(20)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("ElementAccent").opacity(0.3))
            
            Text("No Budgets")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Set budget limits for different\ncategories to track your spending")
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent").opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: { showAddBudget = true }) {
                Text("Create Budget")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color("ActionPrimary"))
                    .cornerRadius(25)
            }
            .padding(.top, 10)
        }
    }
}

struct BudgetCard: View {
    @ObservedObject var dataManager = DataManager.shared
    let budget: Budget
    @State private var showDeleteAlert = false
    
    var progressColor: Color {
        if budget.isOverBudget {
            return .red
        } else if budget.progress > 0.8 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                // Category
                HStack(spacing: 12) {
                    Text(budget.category.icon)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.category.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("ElementAccent"))
                        
                        Text(budget.period.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(Color("ElementAccent").opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Delete Button
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color("ElementAccent").opacity(0.1))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: min(geometry.size.width * budget.progress, geometry.size.width), height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("$\(budget.spent, specifier: "%.2f") of $\(budget.limit, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("ElementAccent"))
                    
                    Spacer()
                    
                    Text("\(Int(budget.progress * 100))%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(progressColor)
                }
            }
            
            // Remaining Amount
            if budget.isOverBudget {
                Text("Over budget by $\(budget.spent - budget.limit, specifier: "%.2f")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("$\(budget.remaining, specifier: "%.2f") remaining")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("ElementAccent").opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
        .alert("Delete Budget", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteBudget(budget)
            }
        } message: {
            Text("Are you sure you want to delete this budget?")
        }
    }
}

#Preview {
    BudgetsView()
}


