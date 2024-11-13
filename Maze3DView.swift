import SwiftUI
import SceneKit

struct Maze3DView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Load the .scn file
        if let scene = SCNScene(named: "MazeScene.scn") {
            sceneView.scene = scene
        }
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Code to update the view if needed
    }
}
