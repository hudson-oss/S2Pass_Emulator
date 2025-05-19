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

@MainActor @propertyWrapper public struct SelectOrder: DynamicProperty {
  @ImmutableUI.Selector<ImmutableData.Store<FoodTruckState, FoodTruckAction>, Never, Order?> public var wrappedValue: Order?
  
  public init(orderID: Order.ID) {
    self._wrappedValue = ImmutableUI.Selector(
      id: orderID,
      label: "SelectOrder(orderID: \(orderID))",
      filter: FoodTruckFilter.filterOrders(),
      outputSelector: FoodTruckState.selectOrder(orderID: orderID)
    )
  }
}
