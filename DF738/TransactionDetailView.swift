//
//  TransactionDetailView.swift
//  DF738
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    let transaction: Transaction
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Amount Card
                        amountCard
                        
                        // Details
                        detailsSection
                        
                        // Delete Button
                        deleteButton
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color("ElementAccent"))
                }
            }
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteTransaction(transaction)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this transaction? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Amount Card
    
    private var amountCard: some View {
        VStack(spacing: 15) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text(transaction.category.icon)
                    .font(.system(size: 40))
            }
            
            // Amount
            Text("\(transaction.type == .income ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .red)
            
            // Category
            Text(transaction.category.rawValue)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("ElementAccent"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(20)
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(spacing: 15) {
            DetailRow(icon: "tag.fill", label: "Type", value: transaction.type.rawValue)
            
            Divider()
            
            DetailRow(icon: "calendar", label: "Date", value: formattedDate)
            
            if !transaction.note.isEmpty {
                Divider()
                DetailRow(icon: "note.text", label: "Note", value: transaction.note)
            }
            
            if transaction.isRecurring {
                Divider()
                DetailRow(icon: "repeat", label: "Recurring", value: transaction.recurringPeriod?.rawValue ?? "Yes")
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(action: { showDeleteAlert = true }) {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete Transaction")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helpers
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transaction.date)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(Color("ElementAccent").opacity(0.7))
            } icon: {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color("ActionPrimary"))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("ElementAccent"))
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    TransactionDetailView(
        transaction: Transaction(
            amount: 150,
            category: .food,
            type: .expense,
            note: "Lunch with friends",
            date: Date()
        )
    )
}


