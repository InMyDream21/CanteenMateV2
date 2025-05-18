import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @State private var isShowingPicker = false

    let months: [String] = Calendar.current.shortMonthSymbols
    let columns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        VStack {
            if isShowingPicker {
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }

                    Text(String(selectedDate.year()))
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .padding(.horizontal, 10)
                        .transition(.opacity)

                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                }
                .padding(10)

                // Month Grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(months, id: \.self) { month in
                        Text(month)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(month == selectedDate.monthName() ? .white : .primary)
                            .frame(width: 70, height: 40)
                            .background(month == selectedDate.monthName() ? Color.blue : Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                selectMonth(month)
                            }
                    }
                }
            } else {
                Button(action: { isShowingPicker.toggle() }) {
                    HStack {
                        Text("\(selectedDate.monthName()) \(String(selectedDate.year()))")
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(7)
                    .frame(minWidth: 120)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                }
            }
        }
        .animation(.easeInOut, value: isShowingPicker)
    }

    private func selectMonth(_ month: String) {
        var dateComponent = DateComponents()
        dateComponent.day = 1
        dateComponent.month = months.firstIndex(of: month)! + 1
        dateComponent.year = selectedDate.year()
        selectedDate = Calendar.current.date(from: dateComponent)!
        isShowingPicker.toggle()
    }
}

extension Date {
    func year() -> Int {
        Calendar.current.component(.year, from: self)
    }

    func monthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
}

#Preview {
    MonthYearPicker(selectedDate: .constant(Date()))
}
