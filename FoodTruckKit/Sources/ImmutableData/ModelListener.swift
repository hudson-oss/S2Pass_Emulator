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

import Combine
import ImmutableData

@MainActor public final class ModelListener {
  private weak var model: FoodTruckModel?
  private var ordersTask: Task<Void, any Error>?
  private var donutsTask: Task<Void, any Error>?
  
  public init() {
    
  }
  
  deinit {
    self.ordersTask?.cancel()
    self.donutsTask?.cancel()
  }
}

extension ModelListener {
  private func listen<S: AsyncSequence>(
    to values: S,
    with dispatcher: some ImmutableData.Dispatcher<FoodTruckState, FoodTruckAction>
  )
  where S.Element == [Order] {
    self.ordersTask?.cancel()
    self.ordersTask = Task {
      for try await orders in values {
        try dispatcher.dispatch(
          action: .data(.modelListener(.didReceiveOrders(orders)))
        )
      }
    }
  }
}

extension ModelListener {
  private func listen<S: AsyncSequence>(
    to values: S,
    with dispatcher: some ImmutableData.Dispatcher<FoodTruckState, FoodTruckAction>
  )
  where S.Element == [Donut] {
    self.donutsTask?.cancel()
    self.donutsTask = Task {
      for try await donuts in values {
        try dispatcher.dispatch(
          action: .data(.modelListener(.didReceiveDonuts(donuts)))
        )
      }
    }
  }
}

extension ModelListener {
  public func listen(
    to model: FoodTruckModel,
    with dispatcher: some ImmutableData.Dispatcher<FoodTruckState, FoodTruckAction>
  ) {
    if self.model !== model {
      self.model = model
      self.listen(
        to: model.$orders.values,
        with: dispatcher
      )
      self.listen(
        to: model.$donuts.values,
        with: dispatcher
      )
    }
  }
}
