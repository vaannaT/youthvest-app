import Foundation
import Combine

struct Holding: Identifiable, Codable {
    var id: String { symbol }
    let symbol: String
    var shares: Int
    var avgPrice: Double
}

struct PortfolioDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

class PortfolioManager: ObservableObject {
    @Published var cash: Double {
        didSet {
            UserDefaults.standard.set(cash, forKey: "youthvest_cash")
        }
    }
    
    @Published var holdings: [String: Holding] {
        didSet {
            if let encoded = try? JSONEncoder().encode(holdings) {
                UserDefaults.standard.set(encoded, forKey: "youthvest_holdings")
            }
        }
    }
    
    let stockPrices: [String: Double] = [
        "AAPL": 182.50,
        "SPY": 510.25,
        "NVDA": 125.75,
        "TSLA": 218.40,
        "MSFT": 428.10
    ]
    
    init() {
        let savedCash = UserDefaults.standard.double(forKey: "youthvest_cash")
        self.cash = savedCash > 0 ? savedCash : 10_000.00
        
        if let data = UserDefaults.standard.data(forKey: "youthvest_holdings"),
           let decoded = try? JSONDecoder().decode([String: Holding].self, from: data) {
            self.holdings = decoded
        } else {
            self.holdings = [:]
        }
    }
    
    var performanceHistory: [PortfolioDataPoint] {
        [
            PortfolioDataPoint(day: "Mon", value: 9_850.00),
            PortfolioDataPoint(day: "Tue", value: 9_920.00),
            PortfolioDataPoint(day: "Wed", value: 10_050.00),
            PortfolioDataPoint(day: "Thu", value: 10_120.00),
            PortfolioDataPoint(day: "Fri", value: 10_080.00),
            PortfolioDataPoint(day: "Sat", value: 10_180.00),
            PortfolioDataPoint(day: "Today", value: netWorth)
        ]
    }
    
    var portfolioStockValue: Double {
        holdings.values.reduce(0.0) { sum, holding in
            let currentPrice = stockPrices[holding.symbol] ?? holding.avgPrice
            return sum + (Double(holding.shares) * currentPrice)
        }
    }
    
    var netWorth: Double {
        cash + portfolioStockValue
    }
    
    func getPrice(for symbol: String) -> Double {
        return stockPrices[symbol.uppercased()] ?? 100.00
    }
    
    func executeBuy(symbol: String, shares: Int) -> Bool {
        let sym = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        guard shares > 0 else { return false }
        
        let price = getPrice(for: sym)
        let totalCost = price * Double(shares)
        guard cash >= totalCost else { return false }
        
        cash -= totalCost
        if var existing = holdings[sym] {
            let totalShares = existing.shares + shares
            let totalSpent = (Double(existing.shares) * existing.avgPrice) + totalCost
            existing.shares = totalShares
            existing.avgPrice = totalSpent / Double(totalShares)
            holdings[sym] = existing
        } else {
            holdings[sym] = Holding(symbol: sym, shares: shares, avgPrice: price)
        }
        return true
    }
    
    func executeSell(symbol: String, shares: Int) -> Bool {
        let sym = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        guard var existing = holdings[sym], existing.shares >= shares, shares > 0 else {
            return false
        }
        
        let price = getPrice(for: sym)
        let totalRevenue = price * Double(shares)
        
        cash += totalRevenue
        existing.shares -= shares
        
        if existing.shares == 0 {
            holdings.removeValue(forKey: sym)
        } else {
            holdings[sym] = existing
        }
        return true
    }
}
