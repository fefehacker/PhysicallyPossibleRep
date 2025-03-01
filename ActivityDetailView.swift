import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @State private var isMazeGamePresented = false
    @Binding var gameSettings: GameSettings

    var body: some View {
        VStack {
            Text(activity.title)
                .font(.largeTitle)
                .padding()

            if let imageName = activity.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }

            Text(activity.description)
                .padding()

            if activity.title == "Maze Game" {
                Button("Launch") {
                    isMazeGamePresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .fullScreenCover(isPresented: $isMazeGamePresented) {
                    Maze3DView(
                        gridWidth: gameSettings.gridWidth,
                        gridHeight: gameSettings.gridHeight,
                        ballFriction: gameSettings.ballFriction,
                        ballMass: gameSettings.ballMass,
                        ballRollingFriction: gameSettings.ballRollingFriction,
                        ballRestitution: gameSettings.ballRestitution,
                        ballDamping: gameSettings.ballDamping,
                        ballRadius: gameSettings.ballRadius,
                        lightIntensity: gameSettings.lightIntensity,
                        cameraHeight: 30.0 // Increased cameraHeight for testing, default is likely lower
                    )
                }
            } else if activity.title == "Space Maze" {
                NavigationLink(destination: SpaceMaze3DView()) {
                    Text("Launch Space Maze 3D")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
    }
}
