import Foundation

struct Activity: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var imageName: String?
    var isMazeGame: Bool = false
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
}
