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

public protocol StoreListenerActivitySession: Sendable {
  @MainActor func startActivity(_ order: Order)
  @MainActor func endActivity(_ order: Order)
}

extension Never: StoreListenerActivitySession {
  public func startActivity(_ order: Order) {
    fatalError()
  }
  
  public func endActivity(_ order: Order) {
    fatalError()
  }
}

@MainActor public final class StoreListener<ActivitySession: StoreListenerActivitySession> {
  private let session: ActivitySession?
  
  private weak var store: AnyObject?
  private var task: Task<Void, any Error>?
  
  public init(session: ActivitySession) {
    self.session = session
  }
  
  public init() where ActivitySession == Never {
    self.session = nil
  }
  
  deinit {
    self.task?.cancel()
  }
}

extension StoreListener {
  private func onReceive(
    _ element: (oldState: FoodTruckState, action: FoodTruckAction.UI.OrderDetailView),
    with model: FoodTruckModel
  ) {
    switch element.action {
    case .onTapStatusButton(let orderID):
      if let session = self.session,
         let order = element.oldState.orders[orderID] {
        if order.status == .placed {
          session.startActivity(order)
        } else if order.status == .preparing {
          session.endActivity(order)
        }
      }
      model.markOrderAsNextStep(id: orderID)
    }
  }
}

extension StoreListener {
  private func onReceive(
    _ element: (oldState: FoodTruckState, action: FoodTruckAction.UI.OrdersView),
    with model: FoodTruckModel
  ) {
    switch element.action {
    case .onTapCompleteOrderButton(let orderID):
      if let session = self.session,
         let order = element.oldState.orders[orderID] {
        if order.status == .preparing {
          session.endActivity(order)
        }
      }
      model.markOrderAsCompleted(id: orderID)
    case .onTapAddOrderButton:
      model.addOrder()
    }
  }
}

extension StoreListener {
  private func onReceive(
    _ element: (oldState: FoodTruckState, action: FoodTruckAction.UI),
    with model: FoodTruckModel
  ) {
    switch element.action {
    case .orderDetailView(let action):
      self.onReceive(
        (element.oldState, action),
        with: model
      )
    case .ordersView(let action):
      self.onReceive(
        (element.oldState, action),
        with: model
      )
    }
  }
}

extension StoreListener {
  private func onReceive(
    _ element: (oldState: FoodTruckState, action: FoodTruckAction),
    with model: FoodTruckModel
  ) {
    switch element.action {
    case .ui(let action):
      self.onReceive(
        (element.oldState, action),
        with: model
      )
    default:
      break
    }
  }
}

extension StoreListener {
  private func listen<S: AsyncSequence>(
    to stream: S,
    with model: FoodTruckModel
  )
  where S.Element == (oldState: FoodTruckState, action: FoodTruckAction) {
    self.task?.cancel()
    self.task = Task {  [weak self] in
      for try await element in stream {
        guard let self = self else { return }
        self.onReceive(
          element,
          with: model
        )
      }
    }
  }
}

extension StoreListener {
  public func listen(
    to store: some ImmutableData.Dispatcher<FoodTruckState, FoodTruckAction> & ImmutableData.Streamer<FoodTruckState, FoodTruckAction> & AnyObject,
    with model: FoodTruckModel
  ) {
    if self.store !== store {
      self.store = store
      self.listen(
        to: store.makeStream(),
        with: model
      )
    }
  }
}
