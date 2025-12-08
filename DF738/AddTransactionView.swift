//
//  AddTransactionView.swift
//  DF738
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var amount: String = ""
    @State private var selectedType: Transaction.TransactionType = .expense
    @State private var selectedCategory: TransactionCategory = .food
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    @State private var recurringPeriod: Transaction.RecurringPeriod = .monthly
    
    var incomeCategories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.isIncome }
    }
    
    var expenseCategories: [TransactionCategory] {
        TransactionCategory.allCases.filter { !$0.isIncome }
    }
    
    var availableCategories: [TransactionCategory] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Type Selector
                        typeSelector
                        
                        // Amount Input
                        amountInput
                        
                        // Category Selector
                        categorySelector
                        
                        // Note Input
                        noteInput
                        
                        // Date Picker
                        datePicker
                        
                        // Recurring Toggle
                        recurringSection
                        
                        // Add Button
                        addButton
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Transaction")
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
    
    // MARK: - Type Selector
    
    private var typeSelector: some View {
        HStack(spacing: 15) {
            TypeButton(
                type: .expense,
                isSelected: selectedType == .expense,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedType = .expense
                        if selectedCategory.isIncome {
                            selectedCategory = .food
                        }
                    }
                }
            )
            
            TypeButton(
                type: .income,
                isSelected: selectedType == .income,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedType = .income
                        if !selectedCategory.isIncome {
                            selectedCategory = .salary
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - Amount Input
    
    private var amountInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Amount")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Category Selector
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(availableCategories, id: \.self) { category in
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
    
    // MARK: - Note Input
    
    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Note (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            TextField("Add a note...", text: $note)
                .font(.system(size: 16))
                .foregroundColor(Color("ElementAccent"))
                .padding()
                .background(Color("BackgroundSecondary"))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Date Picker
    
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            DatePicker("", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding()
                .background(Color("BackgroundSecondary"))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Recurring Section
    
    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $isRecurring) {
                Text("Recurring Transaction")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("ElementAccent"))
            }
            .tint(Color("ActionPrimary"))
            
            if isRecurring {
                Picker("Period", selection: $recurringPeriod) {
                    ForEach(Transaction.RecurringPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(12)
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button(action: addTransaction) {
            Text("Add Transaction")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color("ActionPrimary"), Color("ActionPrimary").opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color("ActionPrimary").opacity(0.3), radius: 8, y: 4)
        }
        .disabled(amount.isEmpty || Double(amount) == nil || Double(amount) == 0)
        .opacity(amount.isEmpty || Double(amount) == nil || Double(amount) == 0 ? 0.5 : 1)
    }
    
    // MARK: - Actions
    
    private func addTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            category: selectedCategory,
            type: selectedType,
            note: note,
            date: date,
            isRecurring: isRecurring,
            recurringPeriod: isRecurring ? recurringPeriod : nil
        )
        
        dataManager.addTransaction(transaction)
        dismiss()
    }
}

// MARK: - Supporting Views

struct TypeButton: View {
    let type: Transaction.TransactionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 20))
                
                Text(type.rawValue)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color("ElementAccent"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? (type == .income ? Color.green : Color.red) : Color("BackgroundSecondary"))
            .cornerRadius(12)
        }
    }
}

struct CategoryButton: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.system(size: 28))
                
                Text(category.rawValue.split(separator: " ").first?.description ?? category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color("ElementAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? category.color : Color("BackgroundSecondary"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    AddTransactionView()
}


