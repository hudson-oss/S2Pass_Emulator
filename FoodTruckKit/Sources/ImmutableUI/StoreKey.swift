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

@MainActor fileprivate struct StoreKey: @preconcurrency EnvironmentKey {
  static let defaultValue = ImmutableData.Store(
    initialState: FoodTruckState(),
    reducer: FoodTruckReducer.reduce
  )
}

extension EnvironmentValues {
  fileprivate var store: ImmutableData.Store<FoodTruckState, FoodTruckAction> {
    get {
      self[StoreKey.self]
    }
    set {
      self[StoreKey.self] = newValue
    }
  }
}

extension ImmutableUI.Provider {
  public init(
    _ store: Store,
    @ViewBuilder content: () -> Content
  )
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction> {
    self.init(
      \.store,
       store,
       content: content
    )
  }
}

extension ImmutableUI.Dispatcher {
  public init()
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction> {
    self.init(\.store)
  }
}

extension ImmutableUI.Selector {
  public init(
    id: some Hashable,
    label: String? = nil,
    filter isIncluded: (@Sendable (Store.State, Store.Action) -> Bool)? = nil,
    dependencySelector: DependencySelector<Store.State, Dependency>,
    outputSelector: OutputSelector<Store.State, Output>
  )
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction> {
    self.init(
      \.store,
       id: id,
       label: label,
       filter: isIncluded,
       dependencySelector: dependencySelector,
       outputSelector: outputSelector
    )
  }
}

extension ImmutableUI.Selector {
  public init(
    id: some Hashable,
    label: String? = nil,
    filter isIncluded: (@Sendable (Store.State, Store.Action) -> Bool)? = nil,
    outputSelector: OutputSelector<Store.State, Output>
  )
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction>, Dependency == Never {
    self.init(
      \.store,
       id: id,
       label: label,
       filter: isIncluded,
       outputSelector: outputSelector
    )
  }
}

extension ImmutableUI.Selector {
  public init(
    label: String? = nil,
    filter isIncluded: (@Sendable (Store.State, Store.Action) -> Bool)? = nil,
    dependencySelector: DependencySelector<Store.State, Dependency>,
    outputSelector: OutputSelector<Store.State, Output>
  )
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction> {
    self.init(
      \.store,
       label: label,
       filter: isIncluded,
       dependencySelector: dependencySelector,
       outputSelector: outputSelector
    )
  }
}

extension ImmutableUI.Selector {
  public init(
    label: String? = nil,
    filter isIncluded: (@Sendable (Store.State, Store.Action) -> Bool)? = nil,
    outputSelector: OutputSelector<Store.State, Output>
  )
  where Store == ImmutableData.Store<FoodTruckState, FoodTruckAction>, Dependency == Never {
    self.init(
      \.store,
       label: label,
       filter: isIncluded,
       outputSelector: outputSelector
    )
  }
}
