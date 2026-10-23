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
                        Text("Total Net Worth")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
                    .chartYScale(domain: 9_500...11_000)
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Current Positions")) {
                    if manager.holdings.isEmpty {
                        Text("No active positions. Open Trade Station to buy shares.")
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

// MARK: - Subview 3: Compound Growth Calculator
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
