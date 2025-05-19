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

public enum FoodTruckReducer {
  @Sendable public static func reduce(
    state: FoodTruckState,
    action: FoodTruckAction
  ) throws -> FoodTruckState {
    switch action {
    case .ui(let action):
      return try self.reduce(state: state, action: action)
    case .data(let action):
      return try self.reduce(state: state, action: action)
    }
  }
}

extension FoodTruckReducer {
  private static func reduce(
    state: FoodTruckState,
    action: FoodTruckAction.UI
  ) throws -> FoodTruckState {
    state
  }
}

extension FoodTruckReducer {
  private static func reduce(
    state: FoodTruckState,
    action: FoodTruckAction.Data
  ) throws -> FoodTruckState {
    switch action {
    case .modelListener(.didReceiveOrders(let orders)):
      var state = state
      state.orders = Dictionary(orders)
      return state
    case .modelListener(.didReceiveDonuts(let donuts)):
      var state = state
      state.donuts = Dictionary(donuts)
      return state
    }
  }
}
