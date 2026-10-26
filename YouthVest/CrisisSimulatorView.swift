import SwiftUI
import Charts

struct CrisisDecision: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let impactMultiplier: Double
    let disciplineScoreDelta: Int
    let feedback: String
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
    
    @State private var selectedScenario: CrisisHistoricalScenario? = nil
    @State private var currentStageIndex: Int = 0
    @State private var simulatedPortfolio: Double = 10_000.0
    @State private var panicBenchmark: Double = 10_000.0
    @State private var disciplineScore: Int = 100
    @State private var simulationLog: [SimulationDataPoint] = [
        SimulationDataPoint(step: 0, portfolioValue: 10_000.0, panicBenchmark: 10_000.0)
    ]
    @State private var latestFeedback: String = ""
    @State private var showFeedbackAlert: Bool = false
    @State private var isCompleted: Bool = false

    let scenarios: [CrisisHistoricalScenario] = [
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
                    marketEventDescription: "Supply chain disruptions and economic volatility cause broad markets to slip 8%.",
                    marketDropPercentage: -0.08,
                    decisions: [
                        CrisisDecision(
                            title: "Dollar-Cost Average",
                            description: "Continue scheduled contributions into broad index funds.",
                            impactMultiplier: 0.96,
                            disciplineScoreDelta: 10,
                            feedback: "Disciplined choice. Buying regular increments through downturns lowers your average cost basis."
                        ),
                        CrisisDecision(
                            title: "Rebalance into Muni Bonds",
                            description: "Shift 15% of equities into civic municipal debt for capital preservation.",
                            impactMultiplier: 0.98,
                            disciplineScoreDelta: 8,
                            feedback: "Prudent risk management. Muni bonds reduce portfolio volatility."
                        ),
                        CrisisDecision(
                            title: "Liquidate to Cash",
                            description: "Sell all stock holdings to lock in capital.",
                            impactMultiplier: 0.92,
                            disciplineScoreDelta: -25,
                            feedback: "Panic move. Selling at the start locks in paper losses and triggers tax friction."
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
                            title: "Hold Course & Do Nothing",
                            description: "Ignore market noise and maintain your 10-year asset allocation.",
                            impactMultiplier: 0.85,
                            disciplineScoreDelta: 15,
                            feedback: "Strong emotional resilience. Resisting the urge to sell at market bottoms preserves recovery upside."
                        ),
                        CrisisDecision(
                            title: "Aggressively Buy the Dip",
                            description: "Deploy reserve cash into high-conviction index ETFs.",
                            impactMultiplier: 0.90,
                            disciplineScoreDelta: 12,
                            feedback: "Opportunistic. Buying during peak fear provides strong multi-year compounding."
                        ),
                        CrisisDecision(
                            title: "Panic Sell Everything",
                            description: "Exit all positions to stop the bleeding.",
                            impactMultiplier: 0.72,
                            disciplineScoreDelta: -30,
                            feedback: "Capitulation. Selling at the trough is the primary cause of retail investor underperformance."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 3,
                    headline: "Stimulus & Rebound",
                    marketEventDescription: "Unprecedented monetary stimulus sparks a rapid 22% technical recovery.",
                    marketDropPercentage: 0.22,
                    decisions: [
                        CrisisDecision(
                            title: "Rebalance to Target Weights",
                            description: "Trim high-flying equities back to your long-term target ratio.",
                            impactMultiplier: 1.15,
                            disciplineScoreDelta: 10,
                            feedback: "Institutional discipline. Systematic rebalancing takes gains off the table safely."
                        ),
                        CrisisDecision(
                            title: "Hold Equities",
                            description: "Let existing diversified index holdings capture the momentum.",
                            impactMultiplier: 1.18,
                            disciplineScoreDelta: 8,
                            feedback: "Effective patience. Staying fully invested captured the full rebound."
                        ),
                        CrisisDecision(
                            title: "FOMO Buy at the Peak",
                            description: "Re-enter the market at the highs after missing the bottom.",
                            impactMultiplier: 1.05,
                            disciplineScoreDelta: -15,
                            feedback: "Classic emotional whipsaw: selling low and re-buying high destroys compounding."
                        )
                    ]
                )
            ]
        ),
        CrisisHistoricalScenario(
            id: "2008_financial_crisis",
            title: "2008 Housing Crunch",
            period: "Sept 2008 - Mar 2009",
            summary: "Liquidity freezes across major financial institutions. Navigate an extended 18-month bear market.",
            icon: "exclamationmark.triangle.fill",
            stages: [
                CrisisStage(
                    stageNumber: 1,
                    headline: "Subprime Credit Shock",
                    marketEventDescription: "Credit markets seize up; major lenders face liquidation as indexes tumble 12%.",
                    marketDropPercentage: -0.12,
                    decisions: [
                        CrisisDecision(
                            title: "Automate DCA Strategy",
                            description: "Commit fixed weekly capital into diversified index ETFs.",
                            impactMultiplier: 0.92,
                            disciplineScoreDelta: 10,
                            feedback: "Great execution. Consistent dollar-cost averaging during structural crises sets up maximum decade-long upside."
                        ),
                        CrisisDecision(
                            title: "Shift to Short-Term Treasuries",
                            description: "Reallocate a portion of holdings to short-term guaranteed yield.",
                            impactMultiplier: 0.96,
                            disciplineScoreDelta: 8,
                            feedback: "Conservative defense. Preserving liquidity shields against prolonged drawdowns."
                        ),
                        CrisisDecision(
                            title: "Short Tech Equities",
                            description: "Use speculative margin to gamble on further declines.",
                            impactMultiplier: 0.82,
                            disciplineScoreDelta: -25,
                            feedback: "Dangerous speculation. Leveraged short bets expose young portfolios to uncapped loss potential."
                        )
                    ]
                ),
                CrisisStage(
                    stageNumber: 2,
                    headline: "Prolonged Recession Bottom",
                    marketEventDescription: "Equities contract an additional 15% as unemployment climbs and credit remains tight.",
                    marketDropPercentage: -0.15,
                    decisions: [
                        CrisisDecision(
                            title: "Maintain 10-Year Horizon",
                            description: "Hold index funds and ignore short-term recession headlines.",
                            impactMultiplier: 0.88,
                            disciplineScoreDelta: 15,
                            feedback: "Mastery of time horizon. Real wealth is created by enduring bear markets without flinching."
                        ),
                        CrisisDecision(
                            title: "Fund Civic Infrastructure Bonds",
                            description: "Support community public debt paying stable yields.",
                            impactMultiplier: 0.94,
                            disciplineScoreDelta: 10,
                            feedback: "Strong civic resilience. Municipal debt stays resilient through private sector contractions."
                        ),
                        CrisisDecision(
                            title: "Capitulate to Cash",
                            description: "Cash out to wait until the economy 'feels safe' again.",
                            impactMultiplier: 0.75,
                            disciplineScoreDelta: -30,
                            feedback: "Costly mistake. By the time economic news sounds safe, the market has usually rebounded 40%."
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
                    // Header Status Card
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
                    
                    // Scenario Selection Cards
                    ForEach(scenarios) { scenario in
                        let completed = manager.completedScenarios.contains(scenario.id)
                        
                        Button(action: { startScenario(scenario) }) {
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
            .sheet(item: $selectedScenario) { scenario in
                scenarioSimulationModal(for: scenario)
            }
            .alert(isPresented: $showFeedbackAlert) {
                Alert(
                    title: Text("Turn Analysis"),
                    message: Text(latestFeedback),
                    dismissButton: .default(Text("Continue")) {
                        advanceStage()
                    }
                )
            }
        }
    }
    
    // MARK: - Interactive Simulation Modal
    private func scenarioSimulationModal(for scenario: CrisisHistoricalScenario) -> some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Score & Net Worth Header
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
                    
                    // Dual-Line Real-Time Comparison Chart
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("PORTFOLIO vs. PANIC BENCHMARK")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .tracking(1)
                            Spacer()
                            HStack(spacing: 10) {
                                HStack(spacing: 4) {
                                    Circle().fill(Color.cyan).frame(width: 6, height: 6)
                                    Text("You").font(.caption2).foregroundColor(.cyan)
                                }
                                HStack(spacing: 4) {
                                    Circle().fill(Color.red).frame(width: 6, height: 6)
                                    Text("Panic Seller").font(.caption2).foregroundColor(.red)
                                }
                            }
                        }
                        
                        Chart(simulationLog) { pt in
                            LineMark(
                                x: .value("Step", pt.step),
                                y: .value("Value", pt.portfolioValue)
                            )
                            .foregroundStyle(Color.cyan)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            LineMark(
                                x: .value("Step", pt.step),
                                y: .value("Panic Value", pt.panicBenchmark)
                            )
                            .foregroundStyle(Color.red.opacity(0.7))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
                            
                            PointMark(
                                x: .value("Step", pt.step),
                                y: .value("Value", pt.portfolioValue)
                            )
                            .foregroundStyle(Color.cyan)
                            .symbolSize(50)
                        }
                        .chartXScale(domain: 0...max(scenario.stages.count, 2))
                        .chartYScale(domain: 6_000...12_500)
                        .frame(height: 160)
                        .chartYAxis {
                            AxisMarks(position: .leading) { val in
                                if let d = val.as(Double.self) {
                                    AxisValueLabel {
                                        Text("$\(Int(d))")
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
                    
                    if !isCompleted && currentStageIndex < scenario.stages.count {
                        let stage = scenario.stages[currentStageIndex]
                        
                        // Stage Briefing
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
                        
                        // Decision Buttons
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
                    } else {
                        // Completion Celebration
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
                            
                            Button(action: {
                                selectedScenario = nil
                            }) {
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
            .navigationBarItems(trailing: Button("Exit") { selectedScenario = nil })
            .navigationTitle(scenario.title)
        }
    }
    
    // MARK: - Simulation Logic
    private func startScenario(_ scenario: CrisisHistoricalScenario) {
        currentStageIndex = 0
        simulatedPortfolio = 10_000.0
        panicBenchmark = 10_000.0
        disciplineScore = 100
        simulationLog = [
            SimulationDataPoint(step: 0, portfolioValue: 10_000.0, panicBenchmark: 10_000.0)
        ]
        isCompleted = false
        selectedScenario = scenario
    }
    
    private func selectDecision(_ decision: CrisisDecision, stage: CrisisStage) {
        simulatedPortfolio = max(simulatedPortfolio * decision.impactMultiplier, 1_000.0)
        panicBenchmark = max(panicBenchmark * (1.0 + (stage.marketDropPercentage * 1.25)), 1_000.0)
        disciplineScore = max(0, min(100, disciplineScore + decision.disciplineScoreDelta))
        
        let step = currentStageIndex + 1
        simulationLog.append(
            SimulationDataPoint(step: step, portfolioValue: simulatedPortfolio, panicBenchmark: panicBenchmark)
        )
        
        latestFeedback = decision.feedback
        showFeedbackAlert = true
    }
    
    private func advanceStage() {
        guard let scenario = selectedScenario else { return }
        if currentStageIndex + 1 < scenario.stages.count {
            currentStageIndex += 1
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
