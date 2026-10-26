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

struct TradeTransaction: Identifiable, Codable {
    let id: UUID
    let symbol: String
    let shares: Int
    let price: Double
    let type: String
    let timestamp: Date
}

// MARK: - Civic Impact Bond Model
struct CivicBond: Identifiable, Codable {
    let id: String
    let title: String
    let municipality: String
    let yieldRate: Double
    let parValue: Double
    let impactDescription: String
    let metricName: String
    let metricPerUnit: Double
    var unitsOwned: Int
}

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
        didSet { UserDefaults.standard.set(cash, forKey: "youthvest_cash") }
    }
    
    @Published var holdings: [String: Holding] {
        didSet {
            if let encoded = try? JSONEncoder().encode(holdings) {
                UserDefaults.standard.set(encoded, forKey: "youthvest_holdings")
            }
        }
    }
    
    @Published var transactions: [TradeTransaction] {
        didSet {
            if let encoded = try? JSONEncoder().encode(transactions) {
                UserDefaults.standard.set(encoded, forKey: "youthvest_txns")
            }
        }
    }
    
    @Published var civicBonds: [CivicBond] {
        didSet {
            if let encoded = try? JSONEncoder().encode(civicBonds) {
                UserDefaults.standard.set(encoded, forKey: "youthvest_civic_bonds")
            }
        }
    }
    
    @Published var userXP: Int {
        didSet { UserDefaults.standard.set(userXP, forKey: "youthvest_xp") }
    }
    
    @Published var completedLessons: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(completedLessons), forKey: "youthvest_lessons")
        }
    }
    
    // Stress Test & Crisis Simulator State
    @Published var completedScenarios: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(completedScenarios), forKey: "youthvest_scenarios")
        }
    }
    
    let stockPrices: [String: Double] = [
        "AAPL": 182.50,
        "SPY": 510.25,
        "NVDA": 125.75,
        "TSLA": 218.40,
        "MSFT": 428.10,
        "GOOGL": 165.30
    ]
    
    let defaultBonds: [CivicBond] = [
        CivicBond(
            id: "civic_solar",
            title: "Community Solar & Green Grid Bond",
            municipality: "Regional Clean Power Authority",
            yieldRate: 4.8,
            parValue: 100.0,
            impactDescription: "Funds rooftop solar panel installations and smart batteries across regional public high schools.",
            metricName: "MWh Clean Energy",
            metricPerUnit: 1.2,
            unitsOwned: 0
        ),
        CivicBond(
            id: "civic_water",
            title: "Clean Watershed & Aquifer Bond",
            municipality: "Municipal Water Agency",
            yieldRate: 4.2,
            parValue: 100.0,
            impactDescription: "Upgrades clean municipal water filtration pipelines and drought runoff reservoirs.",
            metricName: "K-Gallons Filtered",
            metricPerUnit: 15.0,
            unitsOwned: 0
        )
    ]
    
    let modules: [AcademyModule] = [
        AcademyModule(
            id: "civic_finance",
            title: "Civic Bonds & Public Works",
            subtitle: "How municipal investing builds community infrastructure.",
            icon: "building.columns.fill",
            xpReward: 100,
            cashBonus: 250.0,
            content: [
                "A municipal bond is a loan you provide to your local city or school district to fund public infrastructure.",
                "Unlike speculative trading, civic bonds pay predictable interest while funding schools, roads, and clean energy.",
                "Civic bonds empower everyday citizens to finance public works that create lasting community benefits."
            ],
            quiz: [
                LessonQuestion(
                    question: "What is the primary civic purpose of a municipal bond?",
                    options: [
                        "Speculating on tech startups",
                        "Lending capital to local government to build public community infrastructure",
                        "Paying corporate executive bonuses",
                        "Purchasing foreign currencies"
                    ],
                    correctIndex: 1,
                    explanation: "Municipal bonds let citizens fund essential community projects like schools, clean water, and public utilities."
                )
            ]
        ),
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
                "For young investors, starting early is the ultimate edge: 10 extra years of compounding can double your ending portfolio.",
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
        )
    ]
    
    init() {
        let savedCash = UserDefaults.standard.double(forKey: "youthvest_cash")
        self.cash = savedCash > 0 ? savedCash : 10_000.00
        self.userXP = UserDefaults.standard.integer(forKey: "youthvest_xp")
        
        if let savedLessons = UserDefaults.standard.stringArray(forKey: "youthvest_lessons") {
            self.completedLessons = Set(savedLessons)
        } else {
            self.completedLessons = []
        }
        
        if let savedScenarios = UserDefaults.standard.stringArray(forKey: "youthvest_scenarios") {
            self.completedScenarios = Set(savedScenarios)
        } else {
            self.completedScenarios = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "youthvest_holdings"),
           let decoded = try? JSONDecoder().decode([String: Holding].self, from: data) {
            self.holdings = decoded
        } else {
            self.holdings = [:]
        }
        
        if let txData = UserDefaults.standard.data(forKey: "youthvest_txns"),
           let decodedTx = try? JSONDecoder().decode([TradeTransaction].self, from: txData) {
            self.transactions = decodedTx
        } else {
            self.transactions = []
        }
        
        if let bondData = UserDefaults.standard.data(forKey: "youthvest_civic_bonds"),
           let decodedBonds = try? JSONDecoder().decode([CivicBond].self, from: bondData) {
            self.civicBonds = decodedBonds
        } else {
            self.civicBonds = [
                CivicBond(
                    id: "civic_solar",
                    title: "Community Solar & Green Grid Bond",
                    municipality: "Regional Clean Power Authority",
                    yieldRate: 4.8,
                    parValue: 100.0,
                    impactDescription: "Funds rooftop solar panel installations and smart batteries across regional public high schools.",
                    metricName: "MWh Clean Energy",
                    metricPerUnit: 1.2,
                    unitsOwned: 0
                ),
                CivicBond(
                    id: "civic_water",
                    title: "Clean Watershed & Aquifer Bond",
                    municipality: "Municipal Water Agency",
                    yieldRate: 4.2,
                    parValue: 100.0,
                    impactDescription: "Upgrades clean municipal water filtration pipelines and drought runoff reservoirs.",
                    metricName: "K-Gallons Filtered",
                    metricPerUnit: 15.0,
                    unitsOwned: 0
                )
            ]
        }
    }
    
    var performanceHistory: [PortfolioDataPoint] {
        let base = max(netWorth - 650.0, 9_500.0)
        return [
            PortfolioDataPoint(day: "Mon", value: base),
            PortfolioDataPoint(day: "Tue", value: base + 110.0),
            PortfolioDataPoint(day: "Wed", value: base + 195.0),
            PortfolioDataPoint(day: "Thu", value: base + 340.0),
            PortfolioDataPoint(day: "Fri", value: base + 420.0),
            PortfolioDataPoint(day: "Sat", value: base + 530.0),
            PortfolioDataPoint(day: "Today", value: netWorth)
        ]
    }
    
    var portfolioStockValue: Double {
        holdings.values.reduce(0.0) { sum, holding in
            let currentPrice = stockPrices[holding.symbol] ?? holding.avgPrice
            return sum + (Double(holding.shares) * currentPrice)
        }
    }
    
    var totalCivicBondValue: Double {
        civicBonds.reduce(0.0) { $0 + (Double($1.unitsOwned) * $1.parValue) }
    }
    
    var netWorth: Double {
        cash + portfolioStockValue + totalCivicBondValue
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
    
    func recordScenarioCompletion(scenarioId: String, score: Int, bonusCash: Double) {
        completedScenarios.insert(scenarioId)
        userXP += score
        cash += bonusCash
    }
    
    func fundCivicBond(bondId: String, units: Int) -> Bool {
        guard units > 0, let index = civicBonds.firstIndex(where: { $0.id == bondId }) else { return false }
        let totalCost = Double(units) * civicBonds[index].parValue
        guard cash >= totalCost else { return false }
        
        cash -= totalCost
        civicBonds[index].unitsOwned += units
        transactions.insert(
            TradeTransaction(id: UUID(), symbol: "MUNI:\(civicBonds[index].id.uppercased())", shares: units, price: civicBonds[index].parValue, type: "CIVIC_BOND", timestamp: Date()),
            at: 0
        )
        return true
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
        
        transactions.insert(TradeTransaction(id: UUID(), symbol: sym, shares: shares, price: price, type: "BUY", timestamp: Date()), at: 0)
        return true
    }
    
    func executeSell(symbol: String, shares: Int) -> Bool {
        let sym = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        guard var existing = holdings[sym], existing.shares >= shares, shares > 0 else { return false }
        let price = getPrice(for: sym)
        let totalRevenue = price * Double(shares)
        
        cash += totalRevenue
        existing.shares -= shares
        
        if existing.shares == 0 {
            holdings.removeValue(forKey: sym)
        } else {
            holdings[sym] = existing
        }
        
        transactions.insert(TradeTransaction(id: UUID(), symbol: sym, shares: shares, price: price, type: "SELL", timestamp: Date()), at: 0)
        return true
    }
}
