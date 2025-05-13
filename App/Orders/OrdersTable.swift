/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The orders table.
*/

import SwiftUI
import FoodTruckKit

struct OrdersTable: View {
    @Binding var sortOrder: [KeyPathComparator<Order>]
    @Binding var selection: Set<Order.ID>
    
    let orders: [Order]
    let onTapCompleteOrderButton: (Order.ID) -> ()
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Order", value: \.id) { order in
                OrderRow(order: order)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Donuts", value: \.totalSales) { order in
                Text(order.totalSales.formatted())
                    .monospacedDigit()
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Status", value: \.status) { order in
                order.status.label
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Date", value: \.creationDate) { order in
                Text(order.formattedDate)
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Details") { order in
                Menu {
                    NavigationLink(value: order.id) {
                        Label("View Details", systemImage: "list.bullet.below.rectangle")
                    }
                    
                    if !order.isComplete {
                        Section {
                            Button {
                                onTapCompleteOrderButton(order.id)
                            } label: {
                                Label("Complete Order", systemImage: "checkmark")
                            }
                        }
                    }
                } label: {
                    Label("Details", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .foregroundColor(.secondary)
            }
            .width(60)
        } rows: {
            Section {
                ForEach(orders) { order in
                    TableRow(order)
                }
            }
        }
    }
}

extension OrdersTable {
    @available(*, deprecated)
    init(
        model: FoodTruckModel,
        selection: Binding<Set<Order.ID>>,
        completedOrder: Binding<Order?>,
        searchText: Binding<String>
    ) {
        fatalError()
    }
}

struct OrdersTable_Previews: PreviewProvider {
    struct Preview: View {
        @State private var sortOrder = [KeyPathComparator(\Order.status, order: .reverse)]
        @State private var selection: Set<Order.ID> = []
        
        private var orders: [Order] {
            Order.previewArray.sorted(using: self.sortOrder)
        }
        
        var body: some View {
            OrdersTable(
                sortOrder: self.$sortOrder,
                selection: self.$selection,
                orders: self.orders
            ) { orderID in
                print(orderID)
            }
        }
    }
    
    static var previews: some View {
        PreviewStore {
            Preview()
        }
    }
}

//struct OrdersTable_Previews: PreviewProvider {
//    static var previews: some View {
//        OrdersTable()
//    }
//}
