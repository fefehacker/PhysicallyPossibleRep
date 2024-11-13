import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()

        let sphere = SCNSphere(radius: 1.0)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, -5)
        scene.rootNode.addChildNode(sphereNode)
        
        scnView.scene = scene
        scnView.backgroundColor = .black
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
