import SwiftUI
import Charts

enum DecisionVerdict: String {
    case optimal = "Optimal Strategy 🎯"
    case cautious = "Cautious Move ⚠️"
    case poor = "Detrimental / Panic ❌"
    
    var color: Color {
        switch self {
        case .optimal: return .green
        case .cautious: return .orange
        case .poor: return .red
        }
    }
}

struct CrisisDecision: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let verdict: DecisionVerdict
    let isCorrect: Bool
    let impactMultiplier: Double
    let disciplineScoreDelta: Int
    let rationale: String
}

struct CrisisStage: Identifiable {
    let id = UUID()
    let stageNumber: Int
    let headline: String
    let marketEventDescription: String
    let marketDropPercentage: Double
    let decisions: [CrisisDecision]
}

struct CrisisHistoricalScenario: Identifiable {
    let id: String
    let title: String
    let period: String
    let summary: String
    let icon: String
    let stages: [CrisisStage]
}

struct SimulationDataPoint: Identifiable {
    let id = UUID()
    let step: Int
    let portfolioValue: Double
    let panicBenchmark: Double
}

struct CrisisSimulatorView: View {
    @ObservedObject var manager: PortfolioManager
    @State private var activeScenario: CrisisHistoricalScenario? = nil

    let scenarios: [CrisisHistoricalScenario] = [
        CrisisHistoricalScenario(
            id: "2008_financial_crisis",
            title: "2008 Housing Crunch",
            period: "Sept 2008 - Dec 2009",
            summary: "Liquidity freezes across major financial institutions. Navigate an extended crisis and capture the generational rebound.",
            icon: "exclamationmark.triangle.fill",
            stages: [
                CrisisStage(
                    stageNumber: 1,
                    headline: "Subprime Credit Shock",
                    marketEventDescription: "Credit markets seize up; major lenders face liquidation as indexes tumble 14%.",
                    marketDropPercentage: -0.14,
                    decisions: [
                        CrisisDecision(
                            title: "Automate DCA Strategy",
                            description: "Commit fixed weekly capital into diversified index ETFs.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.65,
                            disciplineScoreDelta: 10,
                            rationale: "CORRECT: Automated dollar-cost averaging shields you from psychological fear and accumulates cheap shares."
                        ),
                        CrisisDecision(
                            title: "Shift to Short-Term Treasuries",
                            description: "Reallocate a portion of holdings to guaranteed short-term yield.",
                            verdict: .cautious,
                            isCorrect: true,
                            impactMultiplier: 0.40,
                            disciplineScoreDelta: 8,
                            rationale: "ACCEPTABLE: Capital preservation in guaranteed debt protects baseline portfolio liquidity during early financial contagion."
                        ),
                        CrisisDecision(
                            title: "Liquidate Everything to Cash",
                            description: "Sell off all holdings in fear.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 1.0,
                            disciplineScoreDelta: -25,
                            rationale: "INCORRECT: Knee-jerk liquidation crystallizes sharp paper losses and leaves capital stranded."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 2,
                    headline: "Recession Bottom & Capitulation",
                    marketEventDescription: "Markets plunge another 18% as unemployment climbs and credit remains frozen.",
                    marketDropPercentage: -0.18,
                    decisions: [
                        CrisisDecision(
                            title: "Maintain 10-Year Horizon",
                            description: "Hold index positions without panic-selling.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.70,
                            disciplineScoreDelta: 15,
                            rationale: "CORRECT: Generational wealth is forged by enduring bear markets without flinching. Equities consistently recover over multi-year horizons."
                        ),
                        CrisisDecision(
                            title: "Deploy Cash & Buy the Dip",
                            description: "Aggressively accumulate undervalued blue-chip assets.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.50,
                            disciplineScoreDelta: 12,
                            rationale: "CORRECT: Accumulating broad-market index shares during maximum panic produces extraordinary returns on the back end."
                        ),
                        CrisisDecision(
                            title: "Panic Sell at the Bottom",
                            description: "Surrender and dump holdings at rock bottom.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 1.25,
                            disciplineScoreDelta: -30,
                            rationale: "INCORRECT: You sold at the lowest price of the decade. By the time economic headlines sound safe again, stocks will have already doubled."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 3,
                    headline: "The Decade-Long Expansion Begins",
                    marketEventDescription: "Fiscal backstops ignite a massive 28% cyclical rally out of the trough.",
                    marketDropPercentage: 0.28,
                    decisions: [
                        CrisisDecision(
                            title: "Systematically Rebalance",
                            description: "Trim equities back to target allocations to lock in growth.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 1.15,
                            disciplineScoreDelta: 10,
                            rationale: "CORRECT: Systematic rebalancing enforces the discipline of taking profits while preserving momentum."
                        ),
                        CrisisDecision(
                            title: "Stay Fully Invested",
                            description: "Ride the full index momentum upward.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 1.25,
                            disciplineScoreDelta: 8,
                            rationale: "CORRECT: Patiently riding the full expansion carries portfolio value well above starting levels."
                        ),
                        CrisisDecision(
                            title: "FOMO Re-enter at Peak",
                            description: "Try to jump back in after sitting on cash through the entire bottom.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 0.35,
                            disciplineScoreDelta: -20,
                            rationale: "INCORRECT: Hesitating through the bottom and buying back at the top is the textbook pattern of retail underperformance."
                        )
                    ]
                )
            ]
        ),
        CrisisHistoricalScenario(
            id: "2020_flash_crash",
            title: "2020 Flash Crash",
            period: "Feb - Apr 2020",
            summary: "Global markets dropped 34% in 33 days before a historic recovery. Can you maintain discipline?",
            icon: "bolt.fill",
            stages: [
                CrisisStage(
                    stageNumber: 1,
                    headline: "Initial Uncertainty",
                    marketEventDescription: "Supply chain disruptions and macroeconomic volatility cause broad markets to slip 8%.",
                    marketDropPercentage: -0.08,
                    decisions: [
                        CrisisDecision(
                            title: "Dollar-Cost Average (DCA)",
                            description: "Continue scheduled contributions into broad index funds.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.60,
                            disciplineScoreDelta: 10,
                            rationale: "CORRECT: Dollar-cost averaging systematically lowers your average purchase price without trying to time an unpredictable market."
                        ),
                        CrisisDecision(
                            title: "Rebalance into Muni Bonds",
                            description: "Shift 15% of equities into civic municipal debt for capital preservation.",
                            verdict: .cautious,
                            isCorrect: true,
                            impactMultiplier: 0.40,
                            disciplineScoreDelta: 8,
                            rationale: "ACCEPTABLE: Municipal debt provides portfolio stability and insulates against sharp volatility, though it sacrifices some upside."
                        ),
                        CrisisDecision(
                            title: "Liquidate Everything to Cash",
                            description: "Sell all stock holdings to lock in cash.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 1.0,
                            disciplineScoreDelta: -25,
                            rationale: "INCORRECT: Selling at the first tremor locks in paper losses as permanent losses and causes investors to miss eventual recoveries."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 2,
                    headline: "Circuit Breakers Triggered",
                    marketEventDescription: "Markets plunge another 18%. Volatility hits generational highs.",
                    marketDropPercentage: -0.18,
                    decisions: [
                        CrisisDecision(
                            title: "Maintain 10-Year Horizon",
                            description: "Ignore market noise and keep your existing asset allocation intact.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.70,
                            disciplineScoreDelta: 15,
                            rationale: "CORRECT: Emotional endurance during market capitulations is the single greatest predictor of long-term retail investor wealth."
                        ),
                        CrisisDecision(
                            title: "Aggressively Buy the Dip",
                            description: "Deploy reserve cash into high-conviction index ETFs.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 0.50,
                            disciplineScoreDelta: 12,
                            rationale: "CORRECT: Purchasing diversified index funds when fear is highest captures maximum compounding during the eventual recovery."
                        ),
                        CrisisDecision(
                            title: "Panic Sell Everything",
                            description: "Exit all positions to stop the bleeding.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 1.25,
                            disciplineScoreDelta: -30,
                            rationale: "INCORRECT: Capitulating at the absolute trough is the #1 mistake that destroys compounding and locks in severe capital drawdowns."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 3,
                    headline: "Stimulus & Historic Rebound",
                    marketEventDescription: "Unprecedented monetary stimulus sparks a rapid 24% technical recovery.",
                    marketDropPercentage: 0.24,
                    decisions: [
                        CrisisDecision(
                            title: "Systematically Rebalance",
                            description: "Trim high-flying equities back to your long-term target ratio.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 1.15,
                            disciplineScoreDelta: 10,
                            rationale: "CORRECT: Rebalancing locks in gains methodically while maintaining healthy equity exposure for continued growth."
                        ),
                        CrisisDecision(
                            title: "Stay Fully Invested",
                            description: "Let existing diversified index holdings capture the momentum.",
                            verdict: .optimal,
                            isCorrect: true,
                            impactMultiplier: 1.25,
                            disciplineScoreDelta: 8,
                            rationale: "CORRECT: Holding steady allowed your portfolio to participate fully in the rebound, pushing your net worth past starting capital."
                        ),
                        CrisisDecision(
                            title: "FOMO Buy at the Peak",
                            description: "Re-enter the market at local highs after sitting on cash throughout the drop.",
                            verdict: .poor,
                            isCorrect: false,
                            impactMultiplier: 0.35,
                            disciplineScoreDelta: -15,
                            rationale: "INCORRECT: Selling low and buying high is emotional whipsaw trading, the exact habit institutional investors profit from."
                        )
                    ]
                )
            ]
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bolt.shield.fill")
                                .foregroundColor(.orange)
                            Text("BEHAVIORAL STRESS LAB")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .tracking(1)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("\(manager.completedScenarios.count)/\(scenarios.count)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Text("Crisis Time-Machine")
                            .font(.title2)
                            .fontWeight(.heavy)
                        
                        Text("Step into real financial shocks. Practice maintaining emotional discipline and portfolio resilience under severe drawdown pressure.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(18)
                    .background(Color(red: 25/255, green: 22/255, blue: 38/255))
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                    
                    ForEach(scenarios) { scenario in
                        let completed = manager.completedScenarios.contains(scenario.id)
                        
                        Button(action: { activeScenario = scenario }) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(completed ? Color.green.opacity(0.2) : Color.orange.opacity(0.15))
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        Image(systemName: completed ? "checkmark" : scenario.icon)
                                            .font(.title3)
                                            .foregroundColor(completed ? .green : .orange)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(scenario.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(scenario.period)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(scenario.summary)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(18)
                            .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(completed ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("Stress Test")
            .sheet(item: $activeScenario) { scenario in
                ScenarioSessionView(scenario: scenario, manager: manager, onDismiss: {
                    activeScenario = nil
                })
            }
        }
    }
}

// MARK: - Independent Simulation Session View (Guarantees Instant Load)
struct ScenarioSessionView: View {
    let scenario: CrisisHistoricalScenario
    @ObservedObject var manager: PortfolioManager
    let onDismiss: () -> Void

    @State private var currentStageIndex: Int = 0
    @State private var simulatedPortfolio: Double = 10_000.0
    @State private var panicBenchmark: Double = 10_000.0
    @State private var disciplineScore: Int = 100
    @State private var simulationLog: [SimulationDataPoint] = [
        SimulationDataPoint(step: 0, portfolioValue: 10_000.0, panicBenchmark: 10_000.0)
    ]
    @State private var evaluatedDecision: CrisisDecision? = nil
    @State private var showEvaluationModal: Bool = false
    @State private var isCompleted: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Metrics
                    HStack(spacing: 14) {
                        VStack(spacing: 2) {
                            Text("$\(simulatedPortfolio, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundColor(simulatedPortfolio >= 10_000 ? .cyan : .orange)
                            Text("Portfolio Value").font(.caption2).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(14)
                        
                        VStack(spacing: 2) {
                            Text("\(disciplineScore)/100")
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundColor(disciplineScore >= 75 ? .green : .red)
                            Text("Discipline Score").font(.caption2).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(14)
                    }
                    
                    // Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PORTFOLIO VS. PANIC BENCHMARK")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                
                                let diff = simulatedPortfolio - panicBenchmark
                                HStack(spacing: 4) {
                                    Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.caption2)
                                    Text("\(diff >= 0 ? "+" : "")$\(Int(diff)) vs. Panic Seller")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(diff >= 0 ? .green : .red)
                            }
                            Spacer()
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Circle().fill(Color.cyan).frame(width: 8, height: 8)
                                    Text("You").font(.caption2).foregroundColor(.cyan).fontWeight(.semibold)
                                }
                                HStack(spacing: 4) {
                                    Circle().fill(Color.red).frame(width: 8, height: 8)
                                    Text("Panic").font(.caption2).foregroundColor(.red).fontWeight(.semibold)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Capsule())
                        }
                        
                        let allValues = simulationLog.flatMap { [$0.portfolioValue, $0.panicBenchmark] }
                        let minVal = max(0.0, (allValues.min() ?? 8_000.0) * 0.85)
                        let maxVal = max(11_500.0, (allValues.max() ?? 10_000.0) * 1.15)
                        
                        Chart {
                            RuleMark(y: .value("Baseline", 10_000.0))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(Color.gray.opacity(0.4))
                                .annotation(position: .trailing, alignment: .center) {
                                    Text("Start")
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray)
                                }
                            
                            ForEach(simulationLog) { pt in
                                LineMark(
                                    x: .value("Stage", "S\(pt.step)"),
                                    y: .value("Your Value", pt.portfolioValue)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color.cyan)
                                .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round))
                                
                                AreaMark(
                                    x: .value("Stage", "S\(pt.step)"),
                                    yStart: .value("Min", minVal),
                                    yEnd: .value("Your Value", pt.portfolioValue)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan.opacity(0.2), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                PointMark(
                                    x: .value("Stage", "S\(pt.step)"),
                                    y: .value("Your Value", pt.portfolioValue)
                                )
                                .foregroundStyle(Color.cyan)
                                .symbolSize(60)
                                
                                LineMark(
                                    x: .value("Stage", "S\(pt.step)"),
                                    y: .value("Panic Value", pt.panicBenchmark)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color.red.opacity(0.75))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                
                                PointMark(
                                    x: .value("Stage", "S\(pt.step)"),
                                    y: .value("Panic Value", pt.panicBenchmark)
                                )
                                .foregroundStyle(Color.red)
                                .symbolSize(35)
                            }
                        }
                        .chartYScale(domain: minVal...maxVal)
                        .frame(height: 175)
                        .chartYAxis {
                            AxisMarks(position: .leading) { val in
                                if let d = val.as(Double.self) {
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .foregroundStyle(Color.white.opacity(0.08))
                                    AxisValueLabel {
                                        Text("$\(Int(d / 1_000))k")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(18)
                    .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                    .cornerRadius(18)
                    
                    // Stage Content & Decisions
                    if !isCompleted && currentStageIndex < scenario.stages.count {
                        let stage = scenario.stages[currentStageIndex]
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("STAGE \(stage.stageNumber) OF \(scenario.stages.count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Spacer()
                                Text("\(stage.marketDropPercentage >= 0 ? "+" : "")\(Int(stage.marketDropPercentage * 100))% Shift")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(stage.marketDropPercentage >= 0 ? .green : .red)
                            }
                            
                            Text(stage.headline)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(stage.marketEventDescription)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(18)
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(18)
                        
                        VStack(spacing: 12) {
                            ForEach(stage.decisions) { decision in
                                Button(action: { selectDecision(decision, stage: stage) }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(decision.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.forward.circle.fill")
                                                .foregroundColor(.cyan)
                                        }
                                        Text(decision.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(16)
                                    .background(Color(red: 26/255, green: 30/255, blue: 42/255))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .id("session_stage_\(currentStageIndex)")
                    } else {
                        // Finished View
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                            
                            Text("Stress Test Complete!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Final Discipline Score: \(disciplineScore)/100")
                                .font(.headline)
                                .foregroundColor(disciplineScore >= 75 ? .green : .orange)
                            
                            HStack(spacing: 24) {
                                VStack {
                                    Text("+\(disciplineScore)")
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.yellow)
                                    Text("XP Awarded").font(.caption2).foregroundColor(.gray)
                                }
                                VStack {
                                    Text("+$150")
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.green)
                                    Text("Resilience Bonus").font(.caption2).foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                            .cornerRadius(14)
                            
                            Button(action: onDismiss) {
                                Text("Return to Lab")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.cyan)
                                    .foregroundColor(.black)
                                    .cornerRadius(14)
                            }
                            .padding(.top, 10)
                        }
                        .padding(20)
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(18)
                    }
                }
                .padding()
            }
            .background(Color(red: 14/255, green: 16/255, blue: 22/255).ignoresSafeArea())
            .navigationBarItems(trailing: Button("Exit", action: onDismiss))
            .navigationTitle(scenario.title)
            .sheet(isPresented: $showEvaluationModal) {
                if let dec = evaluatedDecision {
                    VStack(spacing: 20) {
                        Circle()
                            .fill(dec.verdict.color.opacity(0.18))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: dec.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(dec.verdict.color)
                            )
                            .padding(.top, 24)
                        
                        Text(dec.verdict.rawValue)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(dec.verdict.color)
                        
                        VStack(spacing: 8) {
                            Text(dec.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(dec.rationale)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding()
                        .background(Color(red: 22/255, green: 25/255, blue: 35/255))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Text("Discipline:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(dec.disciplineScoreDelta >= 0 ? "+" : "")\(dec.disciplineScoreDelta) pts")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(dec.disciplineScoreDelta >= 0 ? .green : .red)
                            }
                            
                            HStack(spacing: 6) {
                                Text("Impact Multiplier:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(dec.impactMultiplier, specifier: "%.2f")x")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showEvaluationModal = false
                            advanceStage()
                        }) {
                            Text("Proceed to Next Stage")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .presentationDetents([.medium])
                    .background(Color(red: 16/255, green: 18/255, blue: 26/255).ignoresSafeArea())
                }
            }
        }
    }

    private func selectDecision(_ decision: CrisisDecision, stage: CrisisStage) {
        let netShift = stage.marketDropPercentage * decision.impactMultiplier
        simulatedPortfolio = max(1_000.0, simulatedPortfolio * (1.0 + netShift))
        
        let panicShift = stage.marketDropPercentage < 0 ? (stage.marketDropPercentage * 1.35) : (stage.marketDropPercentage * 0.4)
        panicBenchmark = max(1_000.0, panicBenchmark * (1.0 + panicShift))
        
        disciplineScore = max(0, min(100, disciplineScore + decision.disciplineScoreDelta))
        
        let step = currentStageIndex + 1
        simulationLog.append(
            SimulationDataPoint(step: step, portfolioValue: simulatedPortfolio, panicBenchmark: panicBenchmark)
        )
        
        evaluatedDecision = decision
        showEvaluationModal = true
    }

    private func advanceStage() {
        if currentStageIndex + 1 < scenario.stages.count {
            withAnimation {
                currentStageIndex += 1
            }
        } else {
            isCompleted = true
            manager.recordScenarioCompletion(
                scenarioId: scenario.id,
                score: disciplineScore,
                bonusCash: 150.0
            )
        }
    }
}
