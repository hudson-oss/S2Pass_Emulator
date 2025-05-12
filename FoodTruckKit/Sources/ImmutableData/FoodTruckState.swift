//
//  Copyright 2025 Rick van Voorden and Bill Fisher
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct FoodTruckState {
  var orders = [Order.ID: Order]()
  var donuts = [Donut.ID: Donut]()
  
  public init() {
    
  }
}

extension FoodTruckState {
  fileprivate func selectDonut(donutID: Donut.ID) -> Donut? {
    self.donuts[donutID]
  }
}

extension FoodTruckState {
  fileprivate func selectDonuts(order: Order) -> [Donut] {
    order.donuts.compactMap { donut in
      self.selectDonut(donutID: donut.id)
    }
  }
}

extension FoodTruckState {
  fileprivate func selectOrders() -> [Order.ID: Order] {
    self.orders.mapValues { order in
      var order = order
      order.donuts = self.selectDonuts(order: order)
      return order
    }
  }
}

extension FoodTruckState {
  fileprivate func selectOrders(searchText: String) -> [Order.ID: Order] {
    if searchText.isEmpty {
      return self.selectOrders()
    }
    return self.selectOrders().filter { (key, value) in
      value.matches(searchText: searchText) || value.donuts.contains(where: { $0.matches(searchText: searchText) })
    }
  }
}

extension FoodTruckState {
  public static func selectOrders(searchText: String) -> @Sendable (Self) -> [Order.ID: Order] {
    { state in state.selectOrders(searchText: searchText) }
  }
}

extension FoodTruckState {
  fileprivate func selectOrdersValues<S: Sequence>(
    searchText: String,
    using sortOrder: S
  ) -> [Order]
  where S.Element == KeyPathComparator<Order> {
    self.selectOrders(searchText: searchText).values.sorted(using: sortOrder)
  }
}

extension FoodTruckState {
  public static func selectOrdersValues<S: Sequence>(
    searchText: String,
    using sortOrder: S
  ) -> @Sendable (Self) -> [Order]
  where S.Element == KeyPathComparator<Order> {
    { state in
      state.selectOrdersValues(
        searchText: searchText,
        using: sortOrder
      )
    }
  }
}

extension FoodTruckState {
  fileprivate func selectOrdersValues<S: Sequence>(
    searchText: String,
    min count: Int,
    using sortOrder: S
  ) -> [Order]
  where S.Element == KeyPathComparator<Order> {
    self.selectOrders(searchText: searchText).values.min(
      count: count,
      using: sortOrder
    )
  }
}

extension FoodTruckState {
  public static func selectOrdersValues<S: Sequence>(
    searchText: String,
    min count: Int,
    using sortOrder: S
  ) -> @Sendable (Self) -> [Order]
  where S.Element == KeyPathComparator<Order> {
    { state in
      state.selectOrdersValues(
        searchText: searchText,
        min: count,
        using: sortOrder
      )
    }
  }
}

extension FoodTruckState {
  fileprivate func selectOrdersStatuses<S: Sequence>(orderIDs: S) -> [Order.ID: OrderStatus]
  where S.Element == Order.ID {
    Dictionary(orderIDs.compactMap { self.orders[$0] }).mapValues { $0.status }
  }
}

extension FoodTruckState {
  public static func selectOrdersStatuses<S: Sequence>(orderIDs: S) -> @Sendable (Self) -> [Order.ID: OrderStatus]
  where S.Element == Order.ID {
    { state in state.selectOrdersStatuses(orderIDs: orderIDs) }
  }
}

extension FoodTruckState {
  fileprivate func selectOrder(orderID: Order.ID) -> Order? {
    guard
      var order = self.orders[orderID]
    else {
      return nil
    }
    order.donuts = self.selectDonuts(order: order)
    return order
  }
}

extension FoodTruckState {
  public static func selectOrder(orderID: Order.ID) -> @Sendable (Self) -> Order? {
    { state in state.selectOrder(orderID: orderID) }
  }
}
