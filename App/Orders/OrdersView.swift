/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The orders view.
*/

import SwiftUI
import FoodTruckKit

fileprivate struct Item<T>: Identifiable
where T: Hashable {
    var id: T
}

@MainActor @propertyWrapper fileprivate struct SelectOrders: @preconcurrency DynamicProperty {
    @State var searchText: String
    @State var sortOrder: [KeyPathComparator<Order>]
    
    @SelectOrdersValues var wrappedValue: [Order]
    
    init(
        searchText: String = "",
        using sortOrder: [KeyPathComparator<Order>] = [
            KeyPathComparator(\Order.status, order: .reverse),
            KeyPathComparator(\Order.creationDate, order: .reverse),
        ]
    ) {
        self.searchText = searchText
        self.sortOrder = sortOrder
        self._wrappedValue = SelectOrdersValues(
            searchText: searchText,
            using: sortOrder
        )
    }
    
    mutating func update() {
        self._wrappedValue.update(
            searchText: self.searchText,
            using: self.sortOrder
        )
    }
}

@MainActor @propertyWrapper fileprivate struct SelectStatuses: @preconcurrency DynamicProperty {
    @State var orderIDs: Set<Order.ID>
    
    @SelectOrdersStatuses var wrappedValue: [Order.ID: OrderStatus]
    
    init(orderIDs: Set<Order.ID> = []) {
        self.orderIDs = orderIDs
        self._wrappedValue = SelectOrdersStatuses(orderIDs: orderIDs)
    }
    
    mutating func update() {
        self._wrappedValue.update(orderIDs: self.orderIDs)
    }
}

struct OrdersView: View {
    @State private var completedOrder: Item<Order.ID>?
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.editMode) private var editMode
    #endif
    
    var displayAsList: Bool {
        #if os(iOS)
        return sizeClass == .compact
        #else
        return false
        #endif
    }
    
    @SelectOrders private var orders: [Order]
    @SelectStatuses private var statuses: [Order.ID: OrderStatus]
    
    @Dispatch private var dispatch
    
    var orderSections: [OrderStatus: [Order]] {
        var result: [OrderStatus: [Order]] = [:]
        orders.forEach { order in
            result[order.status, default: []].append(order)
        }
        return result
    }
    
    var body: some View {
        ZStack {
            if displayAsList {
                list
            } else {
                OrdersTable(
                    sortOrder: _orders.$sortOrder,
                    selection: _statuses.$orderIDs,
                    orders: orders
                ) { orderID in
                    onTapCompleteOrderButton(orderID: orderID)
                    completedOrder = Item(id: orderID)
                }
                    .tableStyle(.inset)
            }
        }
        .navigationTitle("Orders")
        .navigationDestination(for: Order.ID.self) { id in
            OrderDetailView(orderID: id)
        }
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .searchable(text: _orders.$searchText)
        .sheet(item: $completedOrder) { order in
            OrderCompleteView(orderID: order.id)
        }
        .animation(
            .spring(
                response: 0.4,
                dampingFraction: 1
            ),
            value: orders.count
        )
    }
    
    var list: some View {
        List {
            if let orders = orderSections[.placed] {
                Section("New") {
                    orderRows(orders)
                }
            }
            
            if let orders = orderSections[.preparing] {
                Section("Preparing") {
                    orderRows(orders)
                }
            }
            
            if let orders = orderSections[.ready] {
                Section("Ready") {
                    orderRows(orders)
                }
            }
            
            if let orders = orderSections[.completed] {
                Section("Completed") {
                    orderRows(orders)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    func orderRows(_ orders: [Order]) -> some View {
        ForEach(orders) { order in
            NavigationLink(value: order.id) {
                OrderRow(order: order)
                    .badge(order.totalSales)
            }
        }
    }
    
    @ViewBuilder
    var toolbarButtons: some View {
        Button {
            onTapAddOrderButton()
        } label: {
            Label("Create Order", systemImage: "plus")
        }
        
        NavigationLink(value: statuses.first?.key) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(statuses.count != 1)
        
        Button {
            for orderID in statuses.keys {
                onTapCompleteOrderButton(orderID: orderID)
            }
            if let orderID = statuses.first(where: { $0.value != .completed })?.key {
                completedOrder = Item(id: orderID)
            }
        } label: {
            Label("Complete Order", systemImage: "checkmark.circle")
        }
        .disabled(statuses.allSatisfy { $0.value == .completed })
        
        #if os(iOS)
        if editMode?.wrappedValue.isEditing == false {
            Button("Select") {
                editMode?.wrappedValue = .active
            }
        } else {
            EditButton()
        }
        #endif
    }
}

extension OrdersView {
    @available(*, deprecated)
    init(model: FoodTruckModel) {
        self.init()
    }
}

extension OrdersView {
    private func onTapCompleteOrderButton(orderID: Order.ID) {
        do {
            try self.dispatch(.ui(.ordersView(.onTapCompleteOrderButton(orderID: orderID))))
        } catch {
            print(error)
        }
    }
}

extension OrdersView {
    private func onTapAddOrderButton() {
        do {
            try self.dispatch(.ui(.ordersView(.onTapAddOrderButton)))
        } catch {
            print(error)
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var model = FoodTruckModel.preview
        
        var body: some View {
            PreviewStore(model: model) {
                NavigationStack {
                    OrdersView()
                }
            }
        }
    }
    
    static var previews: some View {
        Preview()
        NavigationStack {
            PreviewStore {
                OrdersView()
            }
        }
    }
}
