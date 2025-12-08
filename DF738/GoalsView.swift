//
//  GoalsView.swift
//  DF738
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showAddGoal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                if dataManager.goals.isEmpty {
                    emptyState
                } else {
                    goalsList
                }
            }
            .navigationTitle("Savings Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("ActionPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView()
            }
        }
    }
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(dataManager.goals) { goal in
                    GoalCard(goal: goal)
                }
            }
            .padding(20)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color("ElementAccent").opacity(0.3))
            
            Text("No Goals")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Set savings goals to track your\nprogress towards financial targets")
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent").opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: { showAddGoal = true }) {
                Text("Create Goal")
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

struct GoalCard: View {
    @ObservedObject var dataManager = DataManager.shared
    let goal: SavingsGoal
    @State private var showAddAmount = false
    @State private var showDeleteAlert = false
    @State private var addAmountText = ""
    
    var goalColor: Color {
        switch goal.color {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                // Icon and Name
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(goalColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Text(goal.icon)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("ElementAccent"))
                        
                        if let days = goal.daysRemaining {
                            Text("\(days) days left")
                                .font(.system(size: 12))
                                .foregroundColor(Color("ElementAccent").opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Options Menu
                Menu {
                    Button(action: { showAddAmount = true }) {
                        Label("Add Money", systemImage: "plus.circle")
                    }
                    
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ElementAccent"))
                        .padding(8)
                        .background(Color("ElementAccent").opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Progress
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color("ElementAccent").opacity(0.1))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(goalColor)
                            .frame(width: min(geometry.size.width * goal.progress, geometry.size.width), height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("$\(goal.currentAmount, specifier: "%.2f")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("ElementAccent"))
                    
                    Spacer()
                    
                    Text("$\(goal.targetAmount, specifier: "%.2f")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ElementAccent").opacity(0.7))
                }
            }
            
            // Status
            HStack {
                if goal.isCompleted {
                    Label("Goal Completed!", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                } else {
                    Text("$\(goal.remaining, specifier: "%.2f") to go (\(Int(goal.progress * 100))%)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("ElementAccent").opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
        .alert("Add Money", isPresented: $showAddAmount) {
            TextField("Amount", text: $addAmountText)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if let amount = Double(addAmountText), amount > 0 {
                    dataManager.addToGoal(goal, amount: amount)
                    addAmountText = ""
                }
            }
        } message: {
            Text("How much would you like to add to this goal?")
        }
        .alert("Delete Goal", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteGoal(goal)
            }
        } message: {
            Text("Are you sure you want to delete this goal?")
        }
    }
}

#Preview {
    GoalsView()
}


