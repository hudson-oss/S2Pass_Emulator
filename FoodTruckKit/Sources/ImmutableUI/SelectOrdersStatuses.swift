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

@MainActor @propertyWrapper public struct SelectOrdersStatuses: DynamicProperty {
  @ImmutableUI.Selector<ImmutableData.Store<FoodTruckState, FoodTruckAction>, Never, [Order.ID: OrderStatus]> public var wrappedValue: [Order.ID: OrderStatus]
  
  public init<S: Sequence & Hashable>(orderIDs: S)
  where S.Element == Order.ID {
    self._wrappedValue = ImmutableUI.Selector(
      id: orderIDs,
      label: "SelectOrdersStatuses(orderIDs: \(orderIDs))",
      filter: FoodTruckFilter.filterOrders(),
      outputSelector: FoodTruckState.selectOrdersStatuses(orderIDs: orderIDs)
    )
  }
}

extension SelectOrdersStatuses {
  public mutating func update<S: Sequence & Hashable>(orderIDs: S)
  where S.Element == Order.ID {
    self._wrappedValue.update(
      id: orderIDs,
      label: "SelectOrdersStatuses(orderIDs: \(orderIDs))",
      filter: FoodTruckFilter.filterOrders(),
      outputSelector: FoodTruckState.selectOrdersStatuses(orderIDs: orderIDs)
    )
  }
}
