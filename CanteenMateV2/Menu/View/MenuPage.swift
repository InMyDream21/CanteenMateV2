import SwiftUI
import SwiftData
import Foundation
import CoreSpotlight
import MobileCoreServices

struct MenuPage: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var menus: [Menu]
    
    @State private var isAddMenuPresented = false
    @State private var selectedItem: Menu? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            if menus.isEmpty {
                ContentUnavailableView(label: {
                    Label("No Menu", systemImage: "list.bullet.rectangle.portrait")
                }, description: {
                    Text("Start adding menus to see your list.")
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(menus) { item in
                            MenuItemCard(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
            }
            
            Button(action: {isAddMenuPresented = true}) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.accentColor)
                    .shadow(radius: 4)
            }
            .padding()
            .sheet(isPresented: $isAddMenuPresented) {
                AddMenuModal()
            }
            .sheet(item: $selectedItem) { item in
                EditMenuModal(item: item)
            }
            .presentationDetents([.height(100)])
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Menu.self, configurations: config)
    
    let context = modelContainer.mainContext

    let dummyData = [
        Menu(name:"Mie Ayam", price: 15000),
        Menu(name:"Bakso", price: 15000),
        Menu(name:"Es Jeruk", price: 10000),
    ]

    dummyData.forEach { context.insert($0) }
    
    return MenuPage()
        .modelContainer(modelContainer)
}
