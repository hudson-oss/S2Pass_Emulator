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

import ImmutableData
import ImmutableUI
import SwiftUI

fileprivate struct ID<S: Sequence & Hashable>: Hashable
where S.Element == KeyPathComparator<Order> {
  let searchText: String
  let count: Int?
  let sortOrder: S
  
  init(
    searchText: String,
    min count: Int? = nil,
    sortOrder: S
  ) {
    self.searchText = searchText
    self.count = count
    self.sortOrder = sortOrder
  }
}

@MainActor @propertyWrapper public struct SelectOrdersValues: DynamicProperty {
  @ImmutableUI.Selector<ImmutableData.Store<FoodTruckState, FoodTruckAction>, [Order.ID: Order], [Order]> public var wrappedValue: [Order]
  
  public init<S: Sequence & Hashable>(
    searchText: String = "",
    using sortOrder: S
  )
  where S.Element == KeyPathComparator<Order> {
    self._wrappedValue = ImmutableUI.Selector(
      id: ID(
        searchText: searchText,
        sortOrder: sortOrder
      ),
      label: "SelectOrdersValues(searchText: \"\(searchText)\", using: \(sortOrder))",
      filter: FoodTruckFilter.filterOrders(),
      dependencySelector: FoodTruckState.selectOrders(
        searchText: searchText
      ),
      outputSelector: FoodTruckState.selectOrdersValues(
        searchText: searchText,
        using: sortOrder
      )
    )
  }
  
  public init<S: Sequence & Hashable>(
    searchText: String = "",
    min count: Int,
    using sortOrder: S
  )
  where S.Element == KeyPathComparator<Order> {
    self._wrappedValue = ImmutableUI.Selector(
      id: ID(
        searchText: searchText,
        min: count,
        sortOrder: sortOrder
      ),
      label: "SelectOrdersValues(searchText: \"\(searchText)\", min: \(count), using: \(sortOrder))",
      filter: FoodTruckFilter.filterOrders(),
      dependencySelector: FoodTruckState.selectOrders(
        searchText: searchText
      ),
      outputSelector: FoodTruckState.selectOrdersValues(
        searchText: searchText,
        min: count,
        using: sortOrder
      )
    )
  }
}

extension SelectOrdersValues {
  public init(
    searchText: String = "",
    using sortOrder: KeyPathComparator<Order>
  ) {
    self.init(
      searchText: searchText,
      using: [sortOrder]
    )
  }
}

extension SelectOrdersValues {
  public init(
    searchText: String = "",
    min count: Int,
    using sortOrder: KeyPathComparator<Order>
  ) {
    self.init(
      searchText: searchText,
      min: count,
      using: [sortOrder]
    )
  }
}

extension SelectOrdersValues {
  public mutating func update<S: Sequence & Hashable>(
    searchText: String = "",
    using sortOrder: S
  )
  where S.Element == KeyPathComparator<Order> {
    self._wrappedValue.update(
      id: ID(
        searchText: searchText,
        sortOrder: sortOrder
      ),
      label: "SelectOrdersValues(searchText: \"\(searchText)\", using: \(sortOrder))",
      filter: FoodTruckFilter.filterOrders(),
      dependencySelector: FoodTruckState.selectOrders(
        searchText: searchText
      ),
      outputSelector: FoodTruckState.selectOrdersValues(
        searchText: searchText,
        using: sortOrder
      )
    )
  }
}
