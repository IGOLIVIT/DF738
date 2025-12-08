//
//  AddBudgetView.swift
//  DF738
//

import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var limit: String = ""
    @State private var selectedCategory: TransactionCategory = .food
    @State private var selectedPeriod: Budget.BudgetPeriod = .monthly
    
    var expenseCategories: [TransactionCategory] {
        TransactionCategory.allCases.filter { !$0.isIncome }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Limit Input
                        limitInput
                        
                        // Period Selector
                        periodSelector
                        
                        // Category Selector
                        categorySelector
                        
                        // Add Button
                        addButton
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Create Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("ElementAccent"))
                }
            }
        }
    }
    
    private var limitInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Budget Limit")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                TextField("0.00", text: $limit)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(12)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Period")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            Picker("Period", selection: $selectedPeriod) {
                ForEach(Budget.BudgetPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(expenseCategories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: addBudget) {
            Text("Create Budget")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("ActionPrimary"))
                .cornerRadius(12)
        }
        .disabled(limit.isEmpty || Double(limit) == nil || Double(limit) == 0)
        .opacity(limit.isEmpty || Double(limit) == nil || Double(limit) == 0 ? 0.5 : 1)
    }
    
    private func addBudget() {
        guard let limitValue = Double(limit), limitValue > 0 else { return }
        
        let budget = Budget(category: selectedCategory, limit: limitValue, period: selectedPeriod)
        dataManager.addBudget(budget)
        dismiss()
    }
}

#Preview {
    AddBudgetView()
}


