import SwiftUI

struct SettingsView: View {
    @Binding var gameSettings: GameSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Maze Dimensions")) {
                    Stepper("Width: \(gameSettings.gridWidth)", value: $gameSettings.gridWidth, in: 5...100)
                    Stepper("Height: \(gameSettings.gridHeight)", value: $gameSettings.gridHeight, in: 5...100)
                }

                Section(header: Text("Ball Physics")) {
                    Stepper("Friction: \(String(format: "%.2f", gameSettings.ballFriction))", value: $gameSettings.ballFriction, in: 0.0...2.0, step: 0.1) { _ in
                        gameSettings.ballFriction = Float(roundToDecimal(Double(gameSettings.ballFriction), decimalPlaces: 1))
                    }
                    Stepper("Mass: \(String(format: "%.2f", gameSettings.ballMass))", value: $gameSettings.ballMass, in: 0.1...5.0, step: 0.1) { _ in
                        gameSettings.ballMass = Float(roundToDecimal(Double(gameSettings.ballMass), decimalPlaces: 1))
                    }
                    Stepper("Rolling Friction: \(String(format: "%.2f", gameSettings.ballRollingFriction))", value: $gameSettings.ballRollingFriction, in: 0.0...1.0, step: 0.05) { _ in
                        gameSettings.ballRollingFriction = Float(roundToDecimal(Double(gameSettings.ballRollingFriction), decimalPlaces: 2))
                    }
                    Stepper("Restitution (Bounciness): \(String(format: "%.2f", gameSettings.ballRestitution))", value: $gameSettings.ballRestitution, in: 0.0...1.0, step: 0.05) { _ in
                        gameSettings.ballRestitution = Float(roundToDecimal(Double(gameSettings.ballRestitution), decimalPlaces: 2))
                    }
                    Stepper("Damping: \(String(format: "%.2f", gameSettings.ballDamping))", value: $gameSettings.ballDamping, in: 0.0...1.0, step: 0.05) { _ in
                        gameSettings.ballDamping = Float(roundToDecimal(Double(gameSettings.ballDamping), decimalPlaces: 2))
                    }
                }


                Section(header: Text("Ball Appearance")) {
                    Stepper("Ball Radius: \(String(format: "%.2f", gameSettings.ballRadius))", value: $gameSettings.ballRadius, in: 0.2...1.0, step: 0.05) { _ in
                        gameSettings.ballRadius = Float(roundToDecimal(Double(gameSettings.ballRadius), decimalPlaces: 2))
                    }
                }

                Section(header: Text("Lighting & Camera")) {
                    Stepper("Light Intensity: \(String(format: "%.0f", gameSettings.lightIntensity))", value: $gameSettings.lightIntensity, in: 500...3000, step: 50) { _ in
                        gameSettings.lightIntensity = Float(roundToDecimal(Double(gameSettings.lightIntensity), decimalPlaces: 0))
                    }
                    Stepper("Camera Height: \(String(format: "%.1f", gameSettings.cameraHeight))", value: $gameSettings.cameraHeight, in: 5.0...20.0, step: 0.5) { _ in
                        gameSettings.cameraHeight = Float(roundToDecimal(Double(gameSettings.cameraHeight), decimalPlaces: 1))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func roundToDecimal(_ value: Double, decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return Darwin.round(value * divisor) / divisor
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var settings = GameSettings()

    static var previews: some View {
        SettingsView(gameSettings: $settings)
    }
}
