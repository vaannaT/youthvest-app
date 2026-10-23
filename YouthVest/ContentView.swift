import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var manager = PortfolioManager()
    
    var body: some View {
        TabView {
            PortfolioView(manager: manager)
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
            
            TradeStationView(manager: manager)
                .tabItem {
                    Label("Trade", systemImage: "arrow.left.arrow.right")
                }
            
            AcademyHomeView(manager: manager)
                .tabItem {
                    Label("Academy", systemImage: "graduationcap.fill")
                }
            
            CompoundCalculatorView()
                .tabItem {
                    Label("Growth", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Subview 1: Portfolio View
struct PortfolioView: View {
    @ObservedObject var manager: PortfolioManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Total Net Worth")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.yellow)
                                Text("\(manager.userXP) XP")
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(12)
                        }
                        
                        Text("$\(manager.netWorth, specifier: "%.2f")")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Available Cash")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("$\(manager.cash, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Holdings Value")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("$\(manager.portfolioStockValue, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Performance History")) {
                    Chart(manager.performanceHistory) { point in
                        LineMark(
                            x: .value("Day", point.day),
                            y: .value("Net Worth", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green.gradient)
                        
                        AreaMark(
                            x: .value("Day", point.day),
                            y: .value("Net Worth", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 180)
                    .chartYScale(domain: 9_500...11_500)
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Current Positions")) {
                    if manager.holdings.isEmpty {
                        Text("No active positions. Earn cash in Academy or Trade shares.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(Array(manager.holdings.values)) { holding in
                            let currentPrice = manager.getPrice(for: holding.symbol)
                            let marketVal = Double(holding.shares) * currentPrice
                            let pnl = marketVal - (Double(holding.shares) * holding.avgPrice)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(holding.symbol)
                                        .font(.headline)
                                    Text("\(holding.shares) shares @ $\(holding.avgPrice, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("$\(marketVal, specifier: "%.2f")")
                                        .font(.headline)
                                    Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(pnl >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("YouthVest")
        }
    }
}

// MARK: - Subview 2: Trade Station
struct TradeStationView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var symbol: String = "AAPL"
    @State private var sharesText: String = "1"
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    private var shares: Int {
        Int(sharesText) ?? 0
    }
    
    private var price: Double {
        manager.getPrice(for: symbol)
    }
    
    private var totalCost: Double {
        price * Double(shares)
    }
    
    private var canBuy: Bool {
        shares > 0 && manager.cash >= totalCost
    }
    
    private var canSell: Bool {
        let sym = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        guard let existing = manager.holdings[sym] else { return false }
        return shares > 0 && existing.shares >= shares
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Order Entry")) {
                    HStack {
                        Text("Ticker")
                        Spacer()
                        TextField("AAPL", text: Binding(
                            get: { symbol },
                            set: { symbol = $0.uppercased() }
                        ))
                        .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        #if os(iOS)
                        TextField("1", text: $sharesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("1", text: $sharesText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    HStack {
                        Text("Market Price")
                        Spacer()
                        Text("$\(price, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Estimated Total")
                        Spacer()
                        Text("$\(totalCost, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(canBuy ? .primary : .red)
                    }
                }
                
                Section {
                    Button(action: executeBuy) {
                        Text("Buy Shares")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(canBuy ? Color.blue : Color.gray.opacity(0.3))
                    .disabled(!canBuy)
                    
                    Button(action: executeSell) {
                        Text("Sell Shares")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(canSell ? Color.red : Color.gray.opacity(0.3))
                    .disabled(!canSell)
                }
            }
            .navigationTitle("Trade Station")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Order Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func executeBuy() {
        if manager.executeBuy(symbol: symbol, shares: shares) {
            alertMessage = "Successfully purchased \(shares) share(s) of \(symbol.uppercased())."
        } else {
            alertMessage = "Order failed: Insufficient cash balance."
        }
        showAlert = true
    }
    
    private func executeSell() {
        if manager.executeSell(symbol: symbol, shares: shares) {
            alertMessage = "Successfully sold \(shares) share(s) of \(symbol.uppercased())."
        } else {
            alertMessage = "Order failed: Insufficient shares owned."
        }
        showAlert = true
    }
}

// MARK: - Subview 3: Gamified Academy (Duolingo Style)
struct AcademyHomeView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var activeModule: AcademyModule?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Status Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Financial Mastery")
                                .font(.headline)
                            Text("Complete lessons to unlock virtual seed money.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(manager.completedLessons.count) Done")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    
                    // Lesson Path Cards
                    ForEach(manager.modules) { module in
                        let isCompleted = manager.completedLessons.contains(module.id)
                        
                        Button(action: { activeModule = module }) {
                            HStack(spacing: 16) {
                                Image(systemName: module.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(isCompleted ? .green : .blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(module.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(module.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack(spacing: 12) {
                                        Text("+\(module.xpReward) XP")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                        Text("+$\(Int(module.cashBonus)) Cash")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                                    .foregroundColor(isCompleted ? .green : .gray)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Academy")
            .sheet(item: $activeModule) { module in
                LessonInteractiveModal(manager: manager, module: module)
            }
        }
    }
}

// MARK: - Lesson Interactive Modal (Slides + Quiz)
struct LessonInteractiveModal: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager: PortfolioManager
    let module: AcademyModule
    
    @State private var currentSlide: Int = 0
    @State private var selectedAnswer: Int?
    @State private var showFeedback: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var lessonCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress Bar
                ProgressView(value: Double(currentSlide + 1), total: Double(module.content.count + module.quiz.count))
                    .tint(.green)
                    .padding(.horizontal)
                
                if currentSlide < module.content.contentCount {
                    // Flashcard Slide View
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: module.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(module.content[currentSlide])
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer()
                    
                    Button(action: {
                        withAnimation { currentSlide += 1 }
                    }) {
                        Text("Continue")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                } else if !lessonCompleted {
                    // Quiz Question View
                    let quizIndex = currentSlide - module.content.count
                    let q = module.quiz[quizIndex]
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Question \(quizIndex + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(q.question)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<q.options.count, id: \.self) { idx in
                                Button(action: {
                                    if !showFeedback { selectedAnswer = idx }
                                }) {
                                    HStack {
                                        Text(q.options[idx])
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if selectedAnswer == idx {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedAnswer == idx ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if showFeedback {
                        VStack(spacing: 8) {
                            Text(isAnswerCorrect ? "Correct! 🎯" : "Incorrect")
                                .font(.headline)
                                .foregroundColor(isAnswerCorrect ? .green : .red)
                            Text(q.explanation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        if !showFeedback {
                            guard let ans = selectedAnswer else { return }
                            isAnswerCorrect = (ans == q.correctIndex)
                            showFeedback = true
                        } else {
                            if currentSlide + 1 < module.content.count + module.quiz.count {
                                currentSlide += 1
                                selectedAnswer = nil
                                showFeedback = false
                            } else {
                                manager.completeLesson(moduleId: module.id, xp: module.xpReward, bonusCash: module.cashBonus)
                                lessonCompleted = true
                            }
                        }
                    }) {
                        Text(showFeedback ? (currentSlide + 1 < module.content.count + module.quiz.count ? "Next" : "Finish") : "Check Answer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAnswer != nil ? Color.green : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(selectedAnswer == nil)
                    .padding(.horizontal)
                } else {
                    // Completion Celebration View
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.yellow)
                        
                        Text("Lesson Mastered!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            VStack {
                                Text("+\(module.xpReward)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                Text("XP Earned")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            VStack {
                                Text("+$\(Int(module.cashBonus))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Seed Cash")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)
                    }
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Back to Academy")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
}

extension Array {
    var contentCount: Int { count }
}

// MARK: - Subview 4: Compound Growth Calculator
struct CompoundCalculatorView: View {
    @State private var monthlySavings: Double = 100.0
    @State private var years: Double = 10.0
    @State private var annualReturn: Double = 8.0
    
    var futureValue: Double {
        let r = annualReturn / 100.0 / 12.0
        let n = years * 12.0
        guard r > 0 else { return monthlySavings * n }
        return monthlySavings * ((pow(1.0 + r, n) - 1.0) / r)
    }
    
    var totalPrincipal: Double {
        monthlySavings * years * 12.0
    }
    
    var interestEarned: Double {
        futureValue - totalPrincipal
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Projection Parameters")) {
                    VStack(alignment: .leading) {
                        Text("Monthly Contribution: $\(Int(monthlySavings))")
                        Slider(value: $monthlySavings, in: 10...1000, step: 10)
                    }
                    VStack(alignment: .leading) {
                        Text("Investment Horizon: \(Int(years)) Years")
                        Slider(value: $years, in: 1...40, step: 1)
                    }
                    VStack(alignment: .leading) {
                        Text("Expected Annual Return: \(annualReturn, specifier: "%.1f")%")
                        Slider(value: $annualReturn, in: 2...14, step: 0.5)
                    }
                }
                
                Section(header: Text("Growth Breakdown")) {
                    HStack {
                        Text("Total Contributions")
                        Spacer()
                        Text("$\(totalPrincipal, specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Compound Growth")
                        Spacer()
                        Text("$\(interestEarned, specifier: "%.2f")")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("Projected Net Value")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(futureValue, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Compound Engine")
        }
    }
}
