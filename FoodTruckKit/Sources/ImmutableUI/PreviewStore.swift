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

@MainActor public struct PreviewStore<Content>
where Content: View {
  @State private var store: ImmutableData.Store<FoodTruckState, FoodTruckAction>
  @State private var modelListener: ModelListener?
  @State private var storeListener: StoreListener<Never>?
  private let content: Content
  
  private init(
    store: ImmutableData.Store<FoodTruckState, FoodTruckAction>,
    modelListener: ModelListener? = nil,
    storeListener: StoreListener<Never>? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.store = store
    self.modelListener = modelListener
    self.storeListener = storeListener
    self.content = content()
  }
}

extension PreviewStore: View {
  public var body: some View {
    ImmutableUI.Provider(self.store) {
      self.content
    }
  }
}

extension PreviewStore {
  public init(
    model: FoodTruckModel,
    @ViewBuilder content: () -> Content
  ) {
    let store = ImmutableData.Store(
      initialState: FoodTruckState(),
      reducer: FoodTruckReducer.reduce
    )
    let modelListener = ModelListener()
    modelListener.listen(
      to: model,
      with: store
    )
    let storeListener = StoreListener()
    storeListener.listen(
      to: store,
      with: model
    )
    self.init(
      store: store,
      modelListener: modelListener,
      storeListener: storeListener,
      content: content
    )
  }
}

extension PreviewStore {
  public init(
    orders: [Order] = Order.previewArray,
    donuts: [Donut] = Donut.all,
    @ViewBuilder content: () -> Content
  ) {
    do {
      let store = ImmutableData.Store(
        initialState: FoodTruckState(),
        reducer: FoodTruckReducer.reduce
      )
      try store.dispatch(
        action: .data(.modelListener(.didReceiveOrders(orders)))
      )
      try store.dispatch(
        action: .data(.modelListener(.didReceiveDonuts(donuts)))
      )
      self.init(
        store: store,
        content: content
      )
    } catch {
      fatalError("\(error)")
    }
  }
}
