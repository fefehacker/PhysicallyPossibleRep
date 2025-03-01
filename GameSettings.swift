import SwiftUI

struct GameSettings {
    var gridWidth: Int = 15
    var gridHeight: Int = 15
    var ballFriction: Float = 1.0
    var ballMass: Float = 1.2

    var ballRollingFriction: Float = 0.02
    var ballRestitution: Float = 0.8
    var ballDamping: Float = 0.1
    var ballRadius: Float = 0.47
    
    var lightIntensity: Float = 1750.0
    var cameraHeight: Float = 10.0     
}
