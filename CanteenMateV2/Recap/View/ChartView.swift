//
//  ChartView.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 14/05/25.
//

import Charts
import SwiftUI

enum ChartType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
    case profit = "Profit"
    case loss = "Loss"
    case total = "Total"
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let totalAmount: Int
    let date: Date
    let category: ChartType?
}

struct ChartView: View {
    @Environment(\.calendar) private var calendar
    @State private var selectedPoint: ChartDataPoint?
    
    let transactions: [Transaction]
    let filter: RecapFilter
    @Binding var selectedDate: Date
    
    private var filteredTransaction: [Transaction] {
        transactions.filter { txn in calendar.isDate(txn.date, inSameDayAs: selectedDate)}
    }

    var chartData: [ChartDataPoint] {
        switch filter {
        case .daily:
            return dailyChartData()
        case .monthly:
            return monthlyChartData()
        }
    }

    var body: some View {
        VStack{
            Chart {
                ForEach(ChartType.allCases, id: \.self) { type in
                    ForEach(chartData.filter { $0.category == type }) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Amount", data.totalAmount)
                        )
                        .foregroundStyle(by: .value("Type", type.rawValue))
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Amount", data.totalAmount)
                        )
                        .foregroundStyle(by: .value("Type", type.rawValue))
                        .opacity(data.id == selectedPoint?.id ? 1 : 0.3)
                    }
                }
            }
            .chartYScale(domain: .automatic(includesZero: true))
            .chartYAxis {
                AxisMarks { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisValueLabel(formatToIdrAbbreviated(doubleValue))
                    }
                }
            }
            .chartLegend(.visible)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x)
                                    {
                                        let nearest = chartData.min(by: {
                                            abs(
                                                $0.date.timeIntervalSince1970
                                                    - date.timeIntervalSince1970)
                                                < abs(
                                                    $1.date.timeIntervalSince1970
                                                        - date.timeIntervalSince1970
                                                )
                                        })
                                        selectedPoint = nearest
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        selectedPoint = nil
                                    }
                                }
                        )
                }
            }
            .frame(height: 300)
            
            if let point = selectedPoint {
                Text("\(point.date.formatted(date: .abbreviated, time: .omitted)): RP\(Int(point.totalAmount).formattedWithSeparator())")
                    .font(.caption)
                    .padding(8)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .transition(.opacity)
            }
        }
        .padding()
    }

    private func dailyChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)

        return (0..<7).reversed().flatMap { offset -> [ChartDataPoint] in
            guard
                let date = calendar.date(
                    byAdding: .day, value: -offset, to: today)
            else { return [] }
            let label = DateFormatter.shortDayFormatter.string(from: date)

            let dailyTransactions = filteredTransaction
                .filter { calendar.isDate($0.date, inSameDayAs: date) }

            let incomeTotal =
                dailyTransactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }

            let expenseTotal =
                dailyTransactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }

            let netTotal = incomeTotal - expenseTotal

            return [
                ChartDataPoint(
                    label: label, totalAmount: incomeTotal, date: date,
                    category: .income),
                ChartDataPoint(
                    label: label, totalAmount: expenseTotal, date: date,
                    category: .expense),
                ChartDataPoint(
                    label: label, totalAmount: netTotal, date: date,
                    category: .total),
            ]
        }
        .reversed()
    }

    private func monthlyChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let currentMonth = calendar.component(.month, from: selectedDate)

        // Group transactions by day
        let groupedByDay = Dictionary(grouping: filteredTransaction) { txn in
            calendar.startOfDay(for: txn.date)
        }

        // Create a map: [Month (Int): [(date: Date, total: Double)]]
        var monthlyDailyTotals: [Int: [(Date, Int)]] = [:]

        for (date, txns) in groupedByDay {
            let income = txns.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = txns.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            let net = income - expense

            let month = calendar.component(.month, from: date)
            monthlyDailyTotals[month, default: []].append((date, net))
        }

        // Now build chart points from Jan to current month
        return (1...currentMonth).flatMap { month -> [ChartDataPoint] in
            let components = DateComponents(year: year, month: month)
            guard let monthDate = calendar.date(from: components) else {
                return []
            }

            let monthLabel = DateFormatter.shortMonthFormatter.string(from: monthDate)
            let dayTotals = monthlyDailyTotals[month] ?? []

            let profit = dayTotals.filter { $0.1 > 0 }.reduce(0) { $0 + $1.1 }
            let loss = dayTotals.filter { $0.1 < 0 }.reduce(0) { $0 + abs($1.1) }
            let total = profit - loss

            return [
                ChartDataPoint(label: monthLabel, totalAmount: profit, date: monthDate, category: .profit),
                ChartDataPoint(label: monthLabel, totalAmount: loss, date: monthDate, category: .loss),
                ChartDataPoint(label: monthLabel, totalAmount: total, date: monthDate, category: .total),
            ]
        }
    }
}

extension DateFormatter {
    static let shortDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df
    }()

    static let shortMonthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }()
}

extension NumberFormatter {
    static var abbreviatedIDR: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.positiveSuffix = ""
        return formatter
    }
}

func formatToIdrAbbreviated(_ value: Double) -> String {
    switch value {
    case 1_000_000_000...:
        return "\(String(format: "%.1f", value / 1_000_000_000))M"
    case 1_000_000...:
        return "\(String(format: "%.1f", value / 1_000_000))JT"
    case 1_000...:
        return "\(String(format: "%.1f", value / 1_000))K"
    default:
        return "\(Int(value))"
    }
}

extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    let calendar = Calendar.current
    let now = Date()

    let sampleDates = [
        now,
        calendar.date(byAdding: .day, value: -1, to: now)!,
        calendar.date(byAdding: .day, value: -2, to: now)!,
        calendar.date(byAdding: .day, value: -7, to: now)!,
        calendar.date(byAdding: .day, value: -14, to: now)!
    ]

    let dummyData = [
        Transaction(name: "Salary", date: sampleDates[0], amount: 50000, type: .income, count: 1),
        Transaction(name: "Lunch", date: sampleDates[1], amount: 25000, type: .expense, count: 1),
        Transaction(name: "Internet", date: sampleDates[0], amount: 150000, type: .expense, count: 1),
        Transaction(name: "Internet", date: sampleDates[0], amount: 150000, type: .expense, count: 1),
        Transaction(name: "Side Job", date: sampleDates[0], amount: 1000000, type: .income, count: 1),
        Transaction(name: "Groceries", date: sampleDates[0], amount: 200000, type: .expense, count: 1),
    ]

    ChartView(transactions: dummyData, filter: .daily, selectedDate: .constant(Date()))
}
