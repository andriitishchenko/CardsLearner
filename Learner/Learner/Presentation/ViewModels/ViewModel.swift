import Foundation
protocol ViewModel: ObservableObject {
    associatedtype Entity
    var data: [Entity] { get }
    var errorMessage: String? { get }
    func loadData() async
    func handleError(_ error: Error)
}
