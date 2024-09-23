protocol UseCase {
    associatedtype Entity
    
    func execute() async throws -> [Entity]
}
