//import SwiftUI
//import CoreMotion
//import SceneKit
//
//struct MazeView: View {
//    @State private var maze: [[Int]] = []
//    @State private var ballPosition: CGPoint = .zero
//    @State private var motionManager = CMMotionManager()
//    @State private var isSolving = false
//
//    var body: some View {
//        ZStack {
//            ForEach(0..<maze.count, id: \.self) { row in
//                ForEach(0 < [row].count, id: \.self) { col in
//                    Rectangle()
//                        .fill(maze[row][col] == 1 ? Color.white : Color.black)
//                        .frame(width: 200, height: 200)
//                        .position(x: CGFloat(col) * 55, y: CGFloat(row) * 70)
//                }
//            }
//
//            Circle()
//                .fill(Color.red)
//                .frame(width: 20, height: 20)
//                .position(ballPosition) 
//                .onAppear {
//                    startMotionUpdates()
//                }
//        }
//        .onAppear {
//            generateMaze()
//        }
//        .gesture(
//            DragGesture().onEnded { _ in
//                if isSolving {
//                    visualizeDijkstra()
//                }
//            }
//        )
//    }
//
//    private func startMotionUpdates() {
//        if motionManager.isAccelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.001
//            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
//                guard let data = data else { return }
//                updateBallPosition(with: data)
//            }
//        }
//    }
//
//    private func updateBallPosition(with data: CMAccelerometerData) {
//        let x = CGFloat(data.acceleration.x)
//        let y = CGFloat(data.acceleration.y)
//        ballPosition.x += x * 9.81
//        ballPosition.y -= y * 9.81
//
//        
//        ballPosition.x = max(60, min(ballPosition.x, CGFloat(maze[0].count * 65)))
//        ballPosition.y = max(120, min(ballPosition.y, CGFloat(maze.count * 100)))
//    }
//
//    private func generateMaze() {
//        maze = [
//            [1, 0, 1, 1, 1],
//            [1, 0, 0, 0, 1],
//            [1, 1, 1, 0, 1],
//            [1, 0, 1, 1, 1],
//            [1, 1, 1, 0, 1],
//            [1, 0, 1, 1, 1],
//            [1, 0, 0, 0, 1]
//        ]
//        ballPosition = CGPoint(x: 10, y: 10)
//    }
//
//    private func visualizeDijkstra() {
//    }
//}
