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

public enum FoodTruckAction {
  case ui(_ action: UI)
  case data(_ action: Data)
}

extension FoodTruckAction {
  public enum UI {
    case orderDetailView(_ action: OrderDetailView)
    case ordersView(_ action: OrdersView)
  }
}

extension FoodTruckAction.UI {
  public enum OrderDetailView {
    case onTapStatusButton(orderID: Order.ID)
  }
}

extension FoodTruckAction.UI {
  public enum OrdersView {
    case onTapCompleteOrderButton(orderID: Order.ID)
    case onTapAddOrderButton
  }
}

extension FoodTruckAction {
  public enum Data {
    case modelListener(_ action: ModelListener)
  }
}

extension FoodTruckAction.Data {
  public enum ModelListener {
    case didReceiveOrders(_ orders: [Order])
    case didReceiveDonuts(_ donuts: [Donut])
  }
}
