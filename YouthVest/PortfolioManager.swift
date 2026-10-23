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

// MARK: - Gamified Academy Models
struct LessonQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct AcademyModule: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let xpReward: Int
    let cashBonus: Double
    let content: [String]
    let quiz: [LessonQuestion]
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
    
    // User Gamification Stats
    @Published var userXP: Int {
        didSet {
            UserDefaults.standard.set(userXP, forKey: "youthvest_xp")
        }
    }
    
    @Published var completedLessons: Set<String> {
        didSet {
            let array = Array(completedLessons)
            UserDefaults.standard.set(array, forKey: "youthvest_completed_lessons")
        }
    }
    
    let stockPrices: [String: Double] = [
        "AAPL": 182.50,
        "SPY": 510.25,
        "NVDA": 125.75,
        "TSLA": 218.40,
        "MSFT": 428.10
    ]
    
    let modules: [AcademyModule] = [
        AcademyModule(
            id: "stocks_101",
            title: "Stocks & Ownership",
            subtitle: "What actually happens when you buy a share?",
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            xpReward: 50,
            cashBonus: 100.0,
            content: [
                "When you buy a share of stock, you are buying a fractional piece of ownership in that real corporation.",
                "Companies issue stock to raise capital to hire engineers, build new products, and expand infrastructure.",
                "If the company grows profits, each share becomes more valuable, increasing your net worth."
            ],
            quiz: [
                LessonQuestion(
                    question: "What does buying a share of stock represent?",
                    options: [
                        "Loaning money to the government",
                        "Fractional equity ownership in a company",
                        "A guaranteed interest deposit",
                        "A physical piece of office equipment"
                    ],
                    correctIndex: 1,
                    explanation: "Stocks represent fractional ownership (equity) in a corporation."
                )
            ]
        ),
        AcademyModule(
            id: "compound_interest",
            title: "The Compound Engine",
            subtitle: "How time in the market multiplies wealth.",
            icon: "clock.arrow.circlepath",
            xpReward: 75,
            cashBonus: 150.0,
            content: [
                "Compound interest is when you earn returns not just on your initial money, but on previous earnings too.",
                "For high school investors, starting early is the ultimate edge: 10 extra years of compounding can double your ending portfolio.",
                "Consistency beats timing the market. Automating regular contributions is key."
            ],
            quiz: [
                LessonQuestion(
                    question: "Why do young investors have a massive advantage?",
                    options: [
                        "Higher initial income",
                        "Longer time horizons for compound growth",
                        "Guaranteed market returns",
                        "Lower brokerage fees"
                    ],
                    correctIndex: 1,
                    explanation: "Longer time horizons allow compounding to accelerate exponentially over decades."
                )
            ]
        ),
        AcademyModule(
            id: "etfs_diversification",
            title: "Index Funds & ETFs",
            subtitle: "Never put all your eggs in one basket.",
            icon: "square.grid.2x2.fill",
            xpReward: 100,
            cashBonus: 200.0,
            content: [
                "Diversification means spreading your money across many companies to protect against a single one failing.",
                "An ETF (Exchange-Traded Fund) like SPY holds hundreds of top companies simultaneously in a single basket.",
                "Broad-market ETFs reduce company-specific risk while still capturing long-term economic expansion."
            ],
            quiz: [
                LessonQuestion(
                    question: "What is the primary benefit of holding an ETF like SPY?",
                    options: [
                        "Guaranteed daily profits",
                        "Instant diversification across 500 major companies",
                        "Direct management of individual corporate boards",
                        "Tax exemption on all short-term trades"
                    ],
                    correctIndex: 1,
                    explanation: "ETFs track a diverse basket of assets, preventing catastrophe if any single company falters."
                )
            ]
        )
    ]
    
    init() {
        let savedCash = UserDefaults.standard.double(forKey: "youthvest_cash")
        self.cash = savedCash > 0 ? savedCash : 10_000.00
        
        self.userXP = UserDefaults.standard.integer(forKey: "youthvest_xp")
        
        if let savedLessons = UserDefaults.standard.stringArray(forKey: "youthvest_completed_lessons") {
            self.completedLessons = Set(savedLessons)
        } else {
            self.completedLessons = []
        }
        
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
    
    func completeLesson(moduleId: String, xp: Int, bonusCash: Double) {
        guard !completedLessons.contains(moduleId) else { return }
        completedLessons.insert(moduleId)
        userXP += xp
        cash += bonusCash
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
