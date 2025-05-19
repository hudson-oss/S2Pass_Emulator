/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The food truck model.
*/

import SwiftUI
import Combine

@MainActor
public class FoodTruckModel: ObservableObject {
    @Published public private(set) var truck = Truck()
    
    @Published public private(set) var orders: [Order] = []
    @Published public private(set) var donuts = Donut.all
    @Published public var newDonut: Donut
        
    private var dailyOrderSummaries: [City.ID: [OrderSummary]] = [:]
    private var monthlyOrderSummaries: [City.ID: [OrderSummary]] = [:]
    
    private var generator = OrderGenerator.SeededRandomGenerator(seed: 5)
    private let orderGenerator = OrderGenerator(knownDonuts: Donut.all)
    
    public init() {
        newDonut = Donut(
            id: Donut.all.count,
            name: String(localized: "New Donut", comment: "New donut-placeholder name."),
            dough: .plain,
            glaze: .chocolate,
            topping: .sprinkles
        )
        
        let orderGenerator = OrderGenerator(knownDonuts: donuts)
        orders = orderGenerator.todaysOrders()
        dailyOrderSummaries = Dictionary(uniqueKeysWithValues: City.all.map { city in
            (key: city.id, value: orderGenerator.historicalDailyOrders(since: .now, cityID: city.id))
        })
        monthlyOrderSummaries = Dictionary(uniqueKeysWithValues: City.all.map { city in
            (key: city.id, orderGenerator.historicalMonthlyOrders(since: .now, cityID: city.id))
        })
        Task(priority: .background) {
            for _ in 0..<20 {
                try? await Task.sleep(nanoseconds: .secondsToNanoseconds(.random(in: 3 ... 8, using: &generator)))
                Task { @MainActor in
                    addOrder()
                }
            }
        }
    }
    
    public func dailyOrderSummaries(cityID: City.ID) -> [OrderSummary] {
        guard let result = dailyOrderSummaries[cityID] else {
            fatalError("Unknown City ID or daily order summaries were not found for: \(cityID).")
        }
        return result
    }
    
    public func monthlyOrderSummaries(cityID: City.ID) -> [OrderSummary] {
        guard let result = monthlyOrderSummaries[cityID] else {
            fatalError("Unknown City ID or monthly order summaries were not found for: \(cityID).")
        }
        return result
    }
    
    public func donutSales(timeframe: Timeframe) -> [DonutSales] {
        combinedOrderSummary(timeframe: timeframe).sales.map { (id, count) in
            DonutSales(donut: donut(id: id), sales: count)
        }
            
    }
    
    public func donuts(sortedBy sort: DonutSortOrder = .popularity(.month)) -> [Donut] {
        switch sort {
        case .popularity(let timeframe):
            return donutsSortedByPopularity(timeframe: timeframe)
        case .name:
            return donuts.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .flavor(let flavor):
            return donuts.sorted {
                $0.flavors[flavor] > $1.flavors[flavor]
            }
        }
    }
    
    private func combinedOrderSummary(timeframe: Timeframe) -> OrderSummary {
        switch timeframe {
        case .today:
            return orders.reduce(into: .empty) { partialResult, order in
                partialResult.formUnion(order)
            }
            
        case .week:
            return dailyOrderSummaries.values.reduce(into: .empty) { partialResult, summaries in
                summaries.prefix(7).forEach { day in
                    partialResult.formUnion(day)
                }
            }
            
        case .month:
            return dailyOrderSummaries.values.reduce(into: .empty) { partialResult, summaries in
                summaries.prefix(30).forEach { day in
                    partialResult.formUnion(day)
                }
            }
            
        case .year:
            return monthlyOrderSummaries.values.reduce(into: .empty) { partialResult, summaries in
                summaries.forEach { month in
                    partialResult.formUnion(month)
                }
            }
        }
    }
    
    private func donutsSortedByPopularity(timeframe: Timeframe) -> [Donut] {
        let result = combinedOrderSummary(timeframe: timeframe).sales
            .sorted {
                if $0.value > $1.value {
                    return true
                } else if $0.value == $1.value {
                    return $0.key < $1.key
                } else {
                    return false
                }
            }
            .map {
                donut(id: $0.key)
            }
        return result
    }
    
    private func donut(id: Donut.ID) -> Donut {
        donuts[id]
    }
    
    public func donutBinding(id: Donut.ID) -> Binding<Donut> {
        Binding<Donut> {
            self.donuts[id]
        } set: { newValue in
            self.donuts[id] = newValue
        }
    }
    
    func markOrderAsCompleted(id: Order.ID) {
        guard let index = orders.firstIndex(where: { $0.id == id }) else {
            return
        }
        orders[index].status = .completed
    }
}

extension FoodTruckModel {
    func markOrderAsNextStep(id: Order.ID) {
        guard let index = orders.firstIndex(where: { $0.id == id }) else {
            return
        }
        orders[index].markAsNextStep { _ in }
    }
}

extension FoodTruckModel {
    func addOrder() {
        let order = orderGenerator.generateOrder(
            number: orders.count + 1,
            date: .now,
            generator: &generator
        )
        self.orders.append(order)
    }
}

public enum DonutSortOrder: Hashable {
    case popularity(Timeframe)
    case name
    case flavor(Flavor)
}

public enum Timeframe: String, Hashable, CaseIterable, Sendable {
    case today
    case week
    case month
    case year
}

public extension FoodTruckModel {
    static let preview = FoodTruckModel()
}
