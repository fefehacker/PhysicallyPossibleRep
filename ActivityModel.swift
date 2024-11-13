import Foundation

// Conform to Identifiable and Equatable
struct Activity: Identifiable, Equatable {
    var id = UUID() // Unique identifier for each activity
    var title: String
    var description: String
    var imageName: String?
    var isMazeGame: Bool = false // New property to determine if it's a maze game
    
    // Custom equality function based on `id`
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
}
