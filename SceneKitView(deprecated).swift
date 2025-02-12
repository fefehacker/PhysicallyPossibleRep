import SceneKit
import SwiftUI

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = generateMazeScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

func generateMazeScene() -> SCNScene {
    let scene = SCNScene()
    let mazeArray = [
        [1, 1, 1, 1, 1],
        [1, 0, 0, 1, 1],
        [1, 1, 1, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1]
    ]

    let wallHeight: CGFloat = 1.0
    let wallWidth: CGFloat = 1.0
    let wallThickness: CGFloat = 0.2

    for (rowIndex, row) in mazeArray.enumerated() {
        for (colIndex, value) in row.enumerated() {
            if value == 1 {
                let wallNode = createWallNode(width: wallWidth, height: wallHeight, thickness: wallThickness)
                wallNode.position = SCNVector3(CGFloat(colIndex) * wallWidth, 0, CGFloat(rowIndex) * wallHeight)
                scene.rootNode.addChildNode(wallNode)
            }
        }
    }

    //floor
    let floorNode = SCNNode(geometry: SCNFloor())
    floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
    scene.rootNode.addChildNode(floorNode)

    //camera
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(0, 5, 10)
    cameraNode.look(at: SCNVector3(0, 0, 0))
    scene.rootNode.addChildNode(cameraNode)

    return scene
}

func createWallNode(width: CGFloat, height: CGFloat, thickness: CGFloat) -> SCNNode {
    let boxGeometry = SCNBox(width: width, height: height, length: thickness, chamferRadius: 0.02)
    boxGeometry.firstMaterial?.diffuse.contents = UIImage(named: "wood_texture")
    return SCNNode(geometry: boxGeometry)
}

struct MazeSceneView: View {
    var body: some View {
        SceneKitView()
            .edgesIgnoringSafeArea(.all)
    }
}
