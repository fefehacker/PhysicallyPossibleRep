import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @State private var isMazeGamePresented = false  // State to control presentation

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

            if activity.isMazeGame {
                Button("Launch") {
                    isMazeGamePresented = true  // Trigger the presentation of the maze game
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .fullScreenCover(isPresented: $isMazeGamePresented) {
                    Maze3DView()  // Present MazeView when button is tapped
                }
            }

            Spacer()
        }
    }
}
