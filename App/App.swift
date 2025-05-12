/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The single entry point for the Food Truck app on iOS and macOS.
*/

import SwiftUI
import FoodTruckKit
#if canImport(ActivityKit)
import ActivityKit
#endif
import ImmutableData
import ImmutableUI

/// The app's entry point.
///
/// The `FoodTruckApp` object is the app's entry point. Additionally, this is the object that keeps the app's state in the `model` and `store` parameters.
///
@main
struct FoodTruckApp: App {
    /// The app's state.
    @StateObject private var model = FoodTruckModel()
    /// The in-app purchase store's state.
    @StateObject private var accountStore = AccountStore()
    
    @State private var store = ImmutableData.Store(
        initialState: FoodTruckState(),
        reducer: FoodTruckReducer.reduce
    )
    @State private var modelListener = ModelListener()
    #if canImport(ActivityKit)
    @State private var storeListener = StoreListener(session: TruckActivitySession())
    #else
    @State private var storeListener = StoreListener()
    #endif
    
    /// The app's body function.
    ///
    /// This app uses a [`WindowGroup`](https://developer.apple.com/documentation/swiftui/windowgroup) scene, which contains the root view of the app, ``ContentView``.
    /// On macOS, the  [`defaultSize(width:height)`](https://developer.apple.com/documentation/swiftui/scene/defaultsize(_:)) modifier
    /// gives the app an appropriate default size on launch. Similarly, a [`MenuBarExtra`](https://developer.apple.com/documentation/swiftui/menubarextra)
    /// scene is used on macOS to insert a menu into the right side of the menu bar.
    var body: some Scene {
        WindowGroup {
            ImmutableUI.Provider(self.store) {
                ContentView(model: model, accountStore: accountStore)
            }
            .onAppear {
                self.modelListener.listen(
                    to: self.model,
                    with: self.store
                )
            }
            .onAppear {
                self.storeListener.listen(
                    to: self.store,
                    with: self.model
                )
            }
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 650)
        #endif
        
        #if os(macOS)
        MenuBarExtra {
            ScrollView {
                VStack(spacing: 0) {
                    BrandHeader(animated: false, size: .reduced)
                    Text("Donut stuff!")
                }
            }
        } label: {
            Label("Food Truck", systemImage: "box.truck")
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}

#if canImport(ActivityKit)
@MainActor final class TruckActivitySession: StoreListenerActivitySession {
  
}
#endif

#if canImport(ActivityKit)
extension TruckActivitySession {
  private func postNotification() {
    let timerSeconds = 60
    let content = UNMutableNotificationContent()
    content.title = "Donuts are done!"
    content.body = "Time to take them out of the oven."
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timerSeconds), repeats: false)
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                                        content: content, trigger: trigger)
    let notificationCenter = UNUserNotificationCenter.current()
    Task {
      do {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        do {
          try await notificationCenter.add(request)
          print("Posted local notification.")
        } catch {
          print("Error posting local notification: \(error.localizedDescription)")
        }
      } catch {
        print("Error requesting authorization: \(error.localizedDescription)")
      }
    }
  }
}
#endif

#if canImport(ActivityKit)
extension TruckActivitySession {
  func startActivity(_ order: Order) {
    let timerSeconds = 60
    let activityAttributes = TruckActivityAttributes(
      orderID: String(order.id.dropFirst(6)),
      order: order.donuts.map(\.id),
      sales: order.sales,
      activityName: "Order preparation activity."
    )
    
    let future = Date(timeIntervalSinceNow: Double(timerSeconds))
    
    let initialContentState = TruckActivityAttributes.ContentState(timerRange: Date.now...future)
    
    let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 2, to: Date())!)
    
    do {
      let myActivity = try Activity<TruckActivityAttributes>.request(
        attributes: activityAttributes,
        content: activityContent,
        pushType: nil
      )
      print(" Requested MyActivity live activity. ID: \(myActivity.id)")
      postNotification()
    } catch let error {
      print("Error requesting live activity: \(error.localizedDescription)")
    }
  }
}
#endif

#if canImport(ActivityKit)
extension TruckActivitySession {
  func endActivity(_ order: Order) {
    Task {
      for activity in Activity<TruckActivityAttributes>.activities {
        // Check if this is the activity associated with this order.
        if activity.attributes.orderID == String(order.id.dropFirst(6)) {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
      }
    }
  }
}
#endif
