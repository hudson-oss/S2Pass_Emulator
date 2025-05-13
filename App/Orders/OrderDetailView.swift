/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The order detail view.
*/

import SwiftUI
import FoodTruckKit

struct OrderDetailView: View {
    @SelectOrder private var order: Order?
    
    init(orderID: Order.ID) {
        self._order = SelectOrder(orderID: orderID)
    }
    
    @Dispatch private var dispatch
    
    @State private var presentingCompletionSheet = false
    
    private func content(_ order: Order) -> some View {
        List {
            Section("Status") {
                HStack {
                    Text(order.status.title)
                    Spacer()
                    Image(systemName: order.status.iconSystemName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Order Started")
                    Spacer()
                    Text(order.formattedDate)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Donuts") {
                ForEach(order.donuts) { donut in
                    Label {
                        Text(donut.name)
                    } icon: {
                        DonutView(donut: donut)
                    }
                    .badge(order.sales[donut.id]!)
                }
            }
            
            Text("Total Donuts")
                .badge(order.totalSales)
        }
        .navigationTitle(order.id)
        .sheet(isPresented: $presentingCompletionSheet) {
            OrderCompleteView(order: order)
        }
        .onChange(of: order.status) { status in
            if status == .completed {
                presentingCompletionSheet = true
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    onTapStatusButton(orderID: order.id)
                } label: {
                    Label(order.status.buttonTitle, systemImage: order.status.iconSystemName)
                        .symbolVariant(order.isComplete ? .fill : .none)
                }
                .labelStyle(.iconOnly)
                .disabled(order.isComplete || order.status == .ready)
            }
        }
    }
    
    var body: some View {
        if let order = self.order {
            self.content(order)
        } else {
            Text("missing order").padding()
        }
    }
}

extension OrderDetailView {
    @available(*, deprecated)
    init(order: Order) {
        self.init(orderID: order.id)
    }
}

extension OrderDetailView {
    @available(*, deprecated)
    init(order: Binding<Order>) {
        self.init(order: order.wrappedValue)
    }
}

extension OrderDetailView {
    private func onTapStatusButton(orderID: Order.ID) {
        do {
            try self.dispatch(.ui(.orderDetailView(.onTapStatusButton(orderID: orderID))))
        } catch {
            print(error)
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewStore {
            NavigationStack {
                OrderDetailView(orderID: Order.preview.id)
            }
        }
        PreviewStore {
            NavigationStack {
                OrderDetailView(orderID: "")
            }
        }
    }
}
