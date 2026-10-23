import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var manager = PortfolioManager()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(red: 16/255, green: 18/255, blue: 24/255))
    }
    
    var body: some View {
        TabView {
            PortfolioView(manager: manager)
                .tabItem { Label("Portfolio", systemImage: "chart.pie.fill") }
            
            TradeStationView(manager: manager)
                .tabItem { Label("Trade", systemImage: "arrow.left.arrow.right") }
            
            AcademyHomeView(manager: manager)
                .tabItem { Label("Academy", systemImage: "graduationcap.fill") }
            
            CompoundCalculatorView()
                .tabItem { Label("Growth", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Portfolio View
struct PortfolioView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var selectedDay: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Net Worth Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("PORTFOLIO VALUE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .tracking(1)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.yellow)
                                Text("\(manager.userXP) XP")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Text("$\(manager.netWorth, specifier: "%.2f")")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                VStack(alignment: .leading) {
                                    Text("Cash").font(.caption2).foregroundColor(.gray)
                                    Text("$\(manager.cash, specifier: "%.2f")")
                                        .font(.subheadline).fontWeight(.semibold)
                                }
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Circle().fill(Color.cyan).frame(width: 8, height: 8)
                                VStack(alignment: .trailing) {
                                    Text("Stocks").font(.caption2).foregroundColor(.gray)
                                    Text("$\(manager.portfolioStockValue, specifier: "%.2f")")
                                        .font(.subheadline).fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 25/255, green: 30/255, blue: 45/255), Color(red: 18/255, green: 20/255, blue: 30/255)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    
                    // Upward Sloping Performance Trend Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PERFORMANCE TREND")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                
                                if let day = selectedDay, let pt = manager.performanceHistory.first(where: { $0.day == day }) {
                                    Text("$\(pt.value, specifier: "%.2f")")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.cyan)
                                } else {
                                    Text("$\(manager.netWorth, specifier: "%.2f")")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                Text(selectedDay != nil ? selectedDay! : "+6.5%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        let data = manager.performanceHistory
                        let minVal = (data.map(\.value).min() ?? 9_500.0) - 150.0
                        let maxVal = (data.map(\.value).max() ?? 11_000.0) + 150.0
                        
                        Chart {
                            ForEach(data) { point in
                                LineMark(
                                    x: .value("Day", point.day),
                                    y: .value("Net Worth", point.value)
                                )
                                .interpolationMethod(.monotone)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                                
                                AreaMark(
                                    x: .value("Day", point.day),
                                    yStart: .value("Baseline", minVal),
                                    yEnd: .value("Net Worth", point.value)
                                )
                                .interpolationMethod(.monotone)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan.opacity(0.28), Color.cyan.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                if let selectedDay, selectedDay == point.day {
                                    RuleMark(x: .value("Day", selectedDay))
                                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                        .foregroundStyle(Color.white.opacity(0.7))
                                    
                                    PointMark(
                                        x: .value("Day", point.day),
                                        y: .value("Net Worth", point.value)
                                    )
                                    .symbolSize(85)
                                    .foregroundStyle(Color.cyan)
                                    .annotation(position: .top) {
                                        Text("$\(point.value, specifier: "%.0f")")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.cyan)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .chartXSelection(value: $selectedDay)
                        .chartYScale(domain: minVal...maxVal)
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(height: 160)
                        .padding(.top, 6)
                    }
                    .padding(18)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    // Positions Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Holdings Breakdown")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if manager.holdings.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("No positions open yet. Visit Trade Station or earn seed cash in Academy.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        } else {
                            ForEach(Array(manager.holdings.values)) { holding in
                                let currentPrice = manager.getPrice(for: holding.symbol)
                                let marketVal = Double(holding.shares) * currentPrice
                                let pnl = marketVal - (Double(holding.shares) * holding.avgPrice)
                                
                                HStack {
                                    Circle()
                                        .fill(Color.cyan.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(Text(String(holding.symbol.prefix(1))).fontWeight(.bold).foregroundColor(.cyan))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(holding.symbol).font(.headline)
                                        Text("\(holding.shares) shares • Avg $\(holding.avgPrice, specifier: "%.2f")")
                                            .font(.caption2).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("$\(marketVal, specifier: "%.2f")").font(.subheadline).fontWeight(.semibold)
                                        Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(pnl >= 0 ? .green : .red)
                                    }
                                }
                                Divider().background(Color.white.opacity(0.05))
                            }
                        }
                    }
                    .padding(18)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    // Recent Transactions Log
                    if !manager.transactions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Execution Activity")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(manager.transactions.prefix(3)) { tx in
                                HStack {
                                    Image(systemName: tx.type == "BUY" ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                                        .foregroundColor(tx.type == "BUY" ? .green : .red)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(tx.type) \(tx.shares)x \(tx.symbol)")
                                            .font(.subheadline).fontWeight(.medium)
                                        Text(tx.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.caption2).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("$\(Double(tx.shares) * tx.price, specifier: "%.2f")")
                                        .font(.subheadline).fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(18)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("YouthVest")
        }
    }
}

// MARK: - Trade Station View
struct TradeStationView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var symbol: String = "AAPL"
    @State private var sharesText: String = "1"
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    let quickTickers = ["AAPL", "SPY", "NVDA", "TSLA", "MSFT", "GOOGL"]
    
    private var shares: Int { Int(sharesText) ?? 0 }
    private var price: Double { manager.getPrice(for: symbol) }
    private var totalCost: Double { price * Double(shares) }
    private var canBuy: Bool { shares > 0 && manager.cash >= totalCost }
    private var canSell: Bool {
        let sym = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        guard let existing = manager.holdings[sym] else { return false }
        return shares > 0 && existing.shares >= shares
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickTickers, id: \.self) { sym in
                                Button(action: { symbol = sym }) {
                                    VStack(spacing: 4) {
                                        Text(sym).font(.subheadline).fontWeight(.bold)
                                        Text("$\(manager.getPrice(for: sym), specifier: "%.2f")")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(symbol == sym ? Color.cyan.opacity(0.25) : Color(red: 25/255, green: 28/255, blue: 38/255))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(symbol == sym ? Color.cyan : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Asset Ticker")
                            Spacer()
                            TextField("SYMBOL", text: Binding(get: { symbol }, set: { symbol = $0.uppercased() }))
                                .multilineTextAlignment(.trailing)
                                .fontWeight(.bold)
                        }
                        Divider().background(Color.white.opacity(0.08))
                        
                        HStack {
                            Text("Shares")
                            Spacer()
                            #if os(iOS)
                            TextField("1", text: $sharesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .fontWeight(.bold)
                            #else
                            TextField("1", text: $sharesText)
                                .multilineTextAlignment(.trailing)
                                .fontWeight(.bold)
                            #endif
                        }
                        
                        HStack(spacing: 8) {
                            Spacer()
                            ForEach([1, 5, 10, 25], id: \.self) { qty in
                                Button("+\(qty)") {
                                    let current = Int(sharesText) ?? 0
                                    sharesText = "\(current + qty)"
                                }
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            }
                        }
                        Divider().background(Color.white.opacity(0.08))
                        
                        HStack {
                            Text("Market Reference")
                            Spacer()
                            Text("$\(price, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        Divider().background(Color.white.opacity(0.08))
                        
                        HStack {
                            Text("Order Total")
                                .fontWeight(.bold)
                            Spacer()
                            Text("$\(totalCost, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundColor(canBuy ? .cyan : .red)
                        }
                    }
                    .padding(20)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    HStack(spacing: 12) {
                        Button(action: executeBuy) {
                            HStack {
                                Image(systemName: "arrow.down.left")
                                Text("Buy Shares")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canBuy ? Color.green : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(!canBuy)
                        
                        Button(action: executeSell) {
                            HStack {
                                Image(systemName: "arrow.up.right")
                                Text("Sell Shares")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSell ? Color.red : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(!canSell)
                    }
                }
                .padding()
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("Trade Station")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Execution Report"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func executeBuy() {
        if manager.executeBuy(symbol: symbol, shares: shares) {
            alertMessage = "Executed BUY order for \(shares) share(s) of \(symbol.uppercased())."
        } else {
            alertMessage = "Order rejected: Insufficient cash balance."
        }
        showAlert = true
    }
    
    private func executeSell() {
        if manager.executeSell(symbol: symbol, shares: shares) {
            alertMessage = "Executed SELL order for \(shares) share(s) of \(symbol.uppercased())."
        } else {
            alertMessage = "Order rejected: Insufficient shares in holdings."
        }
        showAlert = true
    }
}

// MARK: - Gamified Academy
struct AcademyHomeView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var activeModule: AcademyModule?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Youth Financial Literacy")
                                .font(.headline)
                            Text("Pass quizzes with 100% accuracy to earn seed investing capital.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill").foregroundColor(.orange)
                            Text("\(manager.completedLessons.count)/\(manager.modules.count)")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(18)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    ForEach(manager.modules) { module in
                        let isCompleted = manager.completedLessons.contains(module.id)
                        
                        Button(action: { activeModule = module }) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(isCompleted ? Color.green.opacity(0.2) : Color.cyan.opacity(0.15))
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        Image(systemName: isCompleted ? "checkmark" : module.icon)
                                            .font(.title3)
                                            .foregroundColor(isCompleted ? .green : .cyan)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(module.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(module.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                    
                                    HStack(spacing: 10) {
                                        Text("+\(module.xpReward) XP").font(.caption2).fontWeight(.bold).foregroundColor(.yellow)
                                        Text("+$\(Int(module.cashBonus)) Cash").font(.caption2).fontWeight(.bold).foregroundColor(.green)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            .padding(18)
                            .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(isCompleted ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("Academy")
            .sheet(item: $activeModule) { module in
                LessonInteractiveModal(manager: manager, module: module)
            }
        }
    }
}

// MARK: - Lesson Interactive Modal
struct LessonInteractiveModal: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager: PortfolioManager
    let module: AcademyModule
    
    @State private var currentSlide: Int = 0
    @State private var selectedAnswer: Int?
    @State private var showFeedback: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var hasMistakes: Bool = false
    @State private var lessonCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ProgressView(value: Double(currentSlide + 1), total: Double(module.content.count + module.quiz.count))
                    .tint(hasMistakes ? .orange : .cyan)
                    .padding(.horizontal)
                
                if currentSlide < module.content.count {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: module.icon)
                            .font(.system(size: 64))
                            .foregroundColor(.cyan)
                        
                        Text(module.content[currentSlide])
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer()
                    
                    Button(action: { withAnimation { currentSlide += 1 } }) {
                        Text("Continue")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cyan)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                } else if !lessonCompleted {
                    let quizIndex = currentSlide - module.content.count
                    let q = module.quiz[quizIndex]
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("KNOWLEDGE CHECK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                        
                        Text(q.question)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<q.options.count, id: \.self) { idx in
                                Button(action: {
                                    if !showFeedback { selectedAnswer = idx }
                                }) {
                                    HStack {
                                        Text(q.options[idx])
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        if selectedAnswer == idx {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(.cyan)
                                        }
                                    }
                                    .padding()
                                    .background(Color(red: 26/255, green: 30/255, blue: 42/255))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedAnswer == idx ? Color.cyan : Color.clear, lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if showFeedback {
                        VStack(spacing: 6) {
                            Text(isAnswerCorrect ? "Correct! 🎯" : "Incorrect ❌")
                                .font(.headline)
                                .foregroundColor(isAnswerCorrect ? .green : .red)
                            Text(q.explanation)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        if !showFeedback {
                            guard let ans = selectedAnswer else { return }
                            isAnswerCorrect = (ans == q.correctIndex)
                            if !isAnswerCorrect { hasMistakes = true }
                            showFeedback = true
                        } else {
                            if currentSlide + 1 < module.content.count + module.quiz.count {
                                currentSlide += 1
                                selectedAnswer = nil
                                showFeedback = false
                            } else {
                                if !hasMistakes {
                                    manager.completeLesson(moduleId: module.id, xp: module.xpReward, bonusCash: module.cashBonus)
                                }
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
                    Spacer()
                    if hasMistakes {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.orange)
                            
                            Text("Keep Practicing!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("100% quiz accuracy is required to earn XP and unlock seed cash.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                        
                        Button(action: {
                            currentSlide = 0
                            selectedAnswer = nil
                            showFeedback = false
                            isAnswerCorrect = false
                            hasMistakes = false
                            lessonCompleted = false
                        }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.yellow)
                            
                            Text("Lesson Mastered!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 24) {
                                VStack {
                                    Text("+\(module.xpReward)").font(.title).fontWeight(.heavy).foregroundColor(.yellow)
                                    Text("XP Earned").font(.caption).foregroundColor(.gray)
                                }
                                VStack {
                                    Text("+$\(Int(module.cashBonus))").font(.title).fontWeight(.heavy).foregroundColor(.green)
                                    Text("Seed Cash").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Text("Back to Academy")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
            .background(Color(red: 16/255, green: 18/255, blue: 26/255).ignoresSafeArea())
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
}

// MARK: - Compound Growth Calculator
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
    
    var totalPrincipal: Double { monthlySavings * years * 12.0 }
    var interestEarned: Double { futureValue - totalPrincipal }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Monthly Contribution")
                                Spacer()
                                Text("$\(Int(monthlySavings))").fontWeight(.bold).foregroundColor(.cyan)
                            }
                            Slider(value: $monthlySavings, in: 10...1000, step: 10).tint(.cyan)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Horizon")
                                Spacer()
                                Text("\(Int(years)) Years").fontWeight(.bold).foregroundColor(.cyan)
                            }
                            Slider(value: $years, in: 1...40, step: 1).tint(.cyan)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Annual Return")
                                Spacer()
                                Text("\(annualReturn, specifier: "%.1f")%").fontWeight(.bold).foregroundColor(.cyan)
                            }
                            Slider(value: $annualReturn, in: 2...14, step: 0.5).tint(.cyan)
                        }
                    }
                    .padding(20)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    VStack(spacing: 14) {
                        HStack {
                            Text("Total Principal Saved").foregroundColor(.gray)
                            Spacer()
                            Text("$\(totalPrincipal, specifier: "%.2f")").fontWeight(.semibold)
                        }
                        HStack {
                            Text("Compound Growth Generated").foregroundColor(.gray)
                            Spacer()
                            Text("$\(interestEarned, specifier: "%.2f")").fontWeight(.semibold).foregroundColor(.green)
                        }
                        Divider().background(Color.white.opacity(0.08))
                        HStack {
                            Text("Projected Net Value").fontWeight(.bold)
                            Spacer()
                            Text("$\(futureValue, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(20)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                }
                .padding()
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("Compound Engine")
        }
    }
}
