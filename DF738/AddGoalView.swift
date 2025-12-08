//
//  AddGoalView.swift
//  DF738
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var selectedIcon: String = "💰"
    @State private var selectedColor: String = "blue"
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    
    let icons = ["💰", "💻", "✈️", "🏠", "🚗", "📱", "🎓", "💍", "🎮", "📷"]
    let colors = ["blue", "purple", "orange", "green", "red", "pink", "cyan", "indigo"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Name Input
                        nameInput
                        
                        // Target Amount Input
                        targetAmountInput
                        
                        // Icon Selector
                        iconSelector
                        
                        // Color Selector
                        colorSelector
                        
                        // Deadline Toggle
                        deadlineSection
                        
                        // Add Button
                        addButton
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Create Goal")
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
    
    private var nameInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goal Name")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            TextField("e.g., Emergency Fund", text: $name)
                .font(.system(size: 16))
                .foregroundColor(Color("ElementAccent"))
                .padding()
                .background(Color("BackgroundSecondary"))
                .cornerRadius(12)
        }
    }
    
    private var targetAmountInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Target Amount")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                TextField("0.00", text: $targetAmount)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(12)
        }
    }
    
    private var iconSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Icon")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Text(icon)
                                .font(.system(size: 28))
                                .frame(width: 60, height: 60)
                                .background(selectedIcon == icon ? Color("ActionPrimary").opacity(0.2) : Color("BackgroundSecondary"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedIcon == icon ? Color("ActionPrimary") : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
        }
    }
    
    private var colorSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: { selectedColor = color }) {
                            Circle()
                                .fill(colorFromString(color))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color("ElementAccent") : Color.clear, lineWidth: 3)
                                )
                        }
                    }
                }
            }
        }
    }
    
    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $hasDeadline) {
                Text("Set Deadline")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("ElementAccent"))
            }
            .tint(Color("ActionPrimary"))
            
            if hasDeadline {
                DatePicker("", selection: $deadline, in: Date()..., displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(12)
    }
    
    private var addButton: some View {
        Button(action: addGoal) {
            Text("Create Goal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("ActionPrimary"))
                .cornerRadius(12)
        }
        .disabled(name.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil || Double(targetAmount) == 0)
        .opacity(name.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil || Double(targetAmount) == 0 ? 0.5 : 1)
    }
    
    private func addGoal() {
        guard let targetValue = Double(targetAmount), targetValue > 0 else { return }
        
        let goal = SavingsGoal(
            name: name,
            targetAmount: targetValue,
            deadline: hasDeadline ? deadline : nil,
            icon: selectedIcon,
            color: selectedColor
        )
        
        dataManager.addGoal(goal)
        dismiss()
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        case "pink": return .pink
        case "cyan": return .cyan
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

#Preview {
    AddGoalView()
}


