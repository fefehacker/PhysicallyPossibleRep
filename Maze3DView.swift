import SwiftUI
import SceneKit
import CoreMotion
import UIKit

struct Maze3DView: View { //wraps ui view
    let gridWidth: Int
    let gridHeight: Int
    
    @State private var dfsPath: [SCNVector3] = []
    @State private var regenerateMaze: Bool = false
    @State private var viewId = UUID()
    
    let ballFriction: Float
    let ballMass: Float
    
    @State private var showActivityDetail = false
    @State private var mazeCoordinator: Maze3DUIViewRepresentable.Coordinator?
    
    let ballRollingFriction: Float
    let ballRestitution: Float
    let ballDamping: Float
    let ballRadius: Float
    let lightIntensity: Float
    let cameraHeight: Float
    //setting vars

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Maze3DUIViewRepresentable(
                    gridWidth: gridWidth,
                    gridHeight: gridHeight,
                    ballFriction: ballFriction,
                    ballMass: ballMass,
                    coordinator: $mazeCoordinator,
                    dfsPath: $dfsPath,
                    regenerateMaze: $regenerateMaze,
                    ballRollingFriction: ballRollingFriction,
                    ballRestitution: ballRestitution,
                    ballDamping: ballDamping,
                    ballRadius: ballRadius,
                    lightIntensity: lightIntensity,
                    cameraHeight: cameraHeight
                    //passing parameters
                    //foenem
                )
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Exit")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            if let coordinator = mazeCoordinator,
                               let sceneView = coordinator.sceneView {
                                coordinator.solveMaze(in: sceneView)
                            }
                        }) {
                            Text("Solution")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
//main game and functions relating
struct Maze3DUIViewRepresentable: UIViewRepresentable {
    let gridWidth: Int
    let gridHeight: Int
    let ballFriction: Float
    let ballMass: Float
    
    @Binding var coordinator: Coordinator?
    @Binding var dfsPath: [SCNVector3]
    @Binding var regenerateMaze: Bool
    
    let ballRollingFriction: Float
    let ballRestitution: Float
    let ballDamping: Float
    let ballRadius: Float
    let lightIntensity: Float
    let cameraHeight: Float

    private let motionManager = CMMotionManager()

    private func generateMaze(width: Int, height: Int) -> [[Int]] {
        var maze = Array(repeating: Array(repeating: 1, count: width), count: height)
        var walls = [(Int, Int)]()
        let startX = 1
        let startY = 1
        maze[startY][startX] = 0
        walls.append((startX, startY))

        while !walls.isEmpty {
            let index = Int.random(in: 0..<walls.count)
            let (x, y) = walls.remove(at: index)
            let directions = [(0, -2), (0, 2), (-2, 0), (2, 0)]
            for (dx, dy) in directions.shuffled() {
                let nx = x + dx
                let ny = y + dy
                if nx > 0 && ny > 0 && nx < width - 1 && ny < height - 1 && maze[ny][nx] == 1 {
                    maze[ny][nx] = 0
                    maze[y + dy / 2][x + dx / 2] = 0
                    walls.append((nx, ny))
                }
            }
        }
        return maze
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let coordinator = context.coordinator
        sceneView.scene = generateMazeScene(
            width: gridWidth,
            height: gridHeight,
            coordinator: coordinator,
            ballFriction: ballFriction,
            ballMass: ballMass,
            ballRollingFriction: ballRollingFriction,
            ballRestitution: ballRestitution,
            ballDamping: ballDamping,
            ballRadius: ballRadius,
            lightIntensity: lightIntensity,
            cameraHeight: cameraHeight,
            sceneView: sceneView // pass sceneView
        )
        sceneView.delegate = coordinator
        sceneView.scene?.physicsWorld.contactDelegate = coordinator
        sceneView.allowsCameraControl = true
        sceneView.scene?.background.contents = nil
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X //antialiasing

        if let hdrPath = Bundle.main.path(forResource: "lebombo_4k", ofType: "exr") {
            sceneView.scene?.background.contents = URL(fileURLWithPath: hdrPath) //background set
            sceneView.scene?.lightingEnvironment.contents = URL(fileURLWithPath: hdrPath) //hdrlighting
            sceneView.scene?.lightingEnvironment.intensity = 0.3
            let rotation = SCNMatrix4MakeRotation(Float(120 * 3.14 / 180), 0, 1, 0) //rotated background so the user isnt just facing a wall
            sceneView.scene?.background.contentsTransform = rotation
            sceneView.scene?.lightingEnvironment.contentsTransform = rotation
        } else {
            print("HDRI file not found!") //debug for hdri file not loadfing
        }

        coordinator.sceneView = sceneView
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if regenerateMaze {
            uiView.scene = generateMazeScene(
                width: gridWidth, //grid width
                height: gridHeight, //grid heigjt
                coordinator: context.coordinator, //call coordinator
                ballFriction: ballFriction,
                ballMass: ballMass,
                ballRollingFriction: ballRollingFriction,
                ballRestitution: ballRestitution,
                ballDamping: ballDamping,
                ballRadius: ballRadius,
                lightIntensity: lightIntensity,
                cameraHeight: cameraHeight,
                sceneView: uiView //passing sceneview as well
            )
            regenerateMaze = false //boolean for whether maze needs to be regenerated
        }
    }

    func makeCoordinator() -> Coordinator { //set coordinator
        let coordinator = Coordinator(self)
        self.coordinator = coordinator
        return coordinator
    }

    private func generateMazeScene(width: Int, height: Int, coordinator: Coordinator, ballFriction: Float, ballMass: Float, ballRollingFriction: Float, ballRestitution: Float, ballDamping: Float, ballRadius: Float, lightIntensity: Float, cameraHeight: Float, sceneView: SCNView) -> SCNScene { //add paramter for sceneview
        let scene = SCNScene()
        let light = SCNLight()
        light.type = .omni
        light.intensity = CGFloat(lightIntensity)
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(lightNode)

        let wallHeight: CGFloat = 1.0 //wall height
        let wallWidth: CGFloat = 1.0 //wall width
        let wallThickness: CGFloat = 1.0 //THICK

        let maze = generateMaze(width: width, height: height)
        coordinator.maze = maze

        var start: (x: Int, y: Int)? = nil     //maze generation stuff
        var end: (x: Int, y: Int)? = nil
        for y in 0..<height {
            for x in 0..<width {
                if maze[y][x] == 0 {
                    if start == nil { start = (x, y) }
                    end = (x, y)
                }
            }
        }
        coordinator.start = start
        coordinator.end = end

        if let startPoint = start {
            let startMarker = createMarkerNode(at: startPoint, color: .blue)
            scene.rootNode.addChildNode(startMarker)
            coordinator.startMarkerNode = startMarker //start point msrker
        }

        if let endPoint = end {
            let endMarker = createMarkerNode(at: endPoint, color: .red)
            scene.rootNode.addChildNode(endMarker)
            coordinator.endMarkerNode = endMarker //endpoint marker
        }

        let woodMaterial = SCNMaterial()
        woodMaterial.diffuse.contents = UIImage(named: "WoodFloor051_2K-JPG_Color.jpg")
        woodMaterial.normal.contents = UIImage(named: "WoodFloor051_2K-JPG_NormalGL.jpg") //textures
        woodMaterial.roughness.contents = UIImage(named: "WoodFloor051_2K-JPG_Roughness.jpg")
        let zoomFactor: Float = 2
        woodMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
        woodMaterial.diffuse.wrapS = .repeat
        woodMaterial.diffuse.wrapT = .repeat
        woodMaterial.normal.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
        woodMaterial.normal.wrapS = .repeat
        woodMaterial.normal.wrapT = .repeat
        woodMaterial.roughness.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
        woodMaterial.roughness.wrapS = .repeat
        woodMaterial.roughness.wrapT = .repeat //couldntt see the details well enough so 4x scaling

        let floorGeometry = SCNBox(width: CGFloat(width), height: 0.1, length: CGFloat(height), chamferRadius: 0)
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(Float(width) / 2.0, 0, Float(height) / 2.0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: floorGeometry, options: nil))
        floorNode.physicsBody?.categoryBitMask = 3
        floorNode.physicsBody?.collisionBitMask = 1
        floorNode.geometry?.materials = [woodMaterial]
        scene.rootNode.addChildNode(floorNode)

        let ceilingNode = SCNNode()
        let ceilingGeometry = SCNBox(
            width: CGFloat(width),
            height: 0.1,
            length: CGFloat(height),
            chamferRadius: 0
        )
        ceilingGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        ceilingNode.geometry = ceilingGeometry
        ceilingNode.position = SCNVector3(
            Float(width) / 2.0,
            Float(wallHeight) + 0.5,
            0
        )
        ceilingNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: ceilingGeometry, options: nil))
        ceilingNode.physicsBody?.categoryBitMask = 4
        ceilingNode.physicsBody?.collisionBitMask = 1
        scene.rootNode.addChildNode(ceilingNode)

        let ballRadiusSetting = CGFloat(ballRadius)
        let ballGeometry = SCNSphere(radius: ballRadiusSetting)
        ballGeometry.firstMaterial?.diffuse.contents = UIColor.lightGray
        let ballNode = SCNNode(geometry: ballGeometry)
        let colorTexture = UIImage(named: "Metal062C_2K-JPG_Color.jpg")
        let ballMaterial = SCNMaterial()
        let roughnessTexture = UIImage(named: "Metal062C_2K-JPG_Roughness.jpg")
        let metalnessTexture = UIImage(named: "Metal062C_2K-JPG_Metalness.jpg")
        let normalTexture = UIImage(named: "Metal062C_2K-JPG_NormalGL.jpg")
        ballMaterial.diffuse.contents = colorTexture
        ballMaterial.roughness.contents = roughnessTexture
        ballMaterial.metalness.contents = metalnessTexture
        ballMaterial.normal.contents = normalTexture
        ballNode.position = SCNVector3(1.0, ballRadiusSetting + 0.1, 1.0)
        ballGeometry.firstMaterial = ballMaterial
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: ballGeometry, options: nil))
        ballNode.physicsBody?.mass = CGFloat(ballMass)
        ballNode.physicsBody?.friction = CGFloat(ballFriction)
        ballNode.physicsBody?.rollingFriction = CGFloat(ballRollingFriction)
        ballNode.physicsBody?.restitution = CGFloat(ballRestitution)
        ballNode.physicsBody?.damping = CGFloat(ballDamping)
        ballNode.physicsBody?.angularDamping = 0.05
        ballNode.physicsBody?.categoryBitMask = 1
        ballNode.physicsBody?.contactTestBitMask = 2 | 4
        scene.rootNode.addChildNode(ballNode)

        startAccelerometerUpdates(ballNode: ballNode, coordinator: coordinator)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(Float(width) / 2.0, cameraHeight, Float(height))
        cameraNode.look(at: SCNVector3(Float(width) / 2.0, 0, Float(height) / 2.0))
        cameraNode.name = "cameraNode"
        scene.rootNode.addChildNode(cameraNode)

        //audio implementation
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            let audioSource = SCNAudioSource(url: musicURL)!
            audioSource.volume = 0.2
            audioSource.load()

            
            let playAudioAction = SCNAction.playAudio(audioSource, waitForCompletion: true) // waitForCompletion: true is important for looping

            let loopAction = SCNAction.repeatForever(playAudioAction)

            //loop runs with camera node
            cameraNode.runAction(loopAction)

        } else {
            print("Background music file not found!")
        }


        for y in 0..<height {
            for x in 0..<width {
                if maze[y][x] == 1 {
                    let wallNode = createWallNode(width: wallWidth, height: wallHeight, thickness: wallThickness)
                    let woodMaterial = SCNMaterial()
                    woodMaterial.diffuse.contents = UIImage(named: "WoodFloor051_2K-JPG_Color.jpg")
                    woodMaterial.normal.contents = UIImage(named: "WoodFloor051_2K-JPG_NormalGL.jpg")
                    woodMaterial.roughness.contents = UIImage(named: "WoodFloor051_2K-JPG_Roughness.jpg")
                    let zoomFactor: Float = 0.125
                    woodMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
                    woodMaterial.diffuse.wrapS = .repeat
                    woodMaterial.diffuse.wrapT = .repeat
                    woodMaterial.normal.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
                    woodMaterial.normal.wrapS = .repeat
                    woodMaterial.normal.wrapT = .repeat
                    woodMaterial.roughness.contentsTransform = SCNMatrix4MakeScale(Float(zoomFactor), Float(zoomFactor), 1)
                    woodMaterial.roughness.wrapS = .repeat
                    woodMaterial.roughness.wrapT = .repeat
                    woodMaterial.metalness.contents = 0.2
                    wallNode.position = SCNVector3(Float(x) * Float(wallWidth) + Float(wallWidth) / 2.0, Float(wallHeight) / 2.0, Float(y) * Float(wallHeight) + Float(wallHeight) / 2.0)
                    wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: wallNode.geometry!, options: nil))
                    wallNode.physicsBody?.categoryBitMask = 2
                    wallNode.physicsBody?.contactTestBitMask = 1
                    wallNode.geometry?.materials = [woodMaterial]
                    scene.rootNode.addChildNode(wallNode)
                }
            }
        }

        return scene
    }

    private func createMarkerNode(at position: (x: Int, y: Int), color: UIColor) -> SCNNode { //had to move outside and make as private
        let radius: CGFloat = 0.4
        let marker = SCNCylinder(radius: radius, height: 0.2)
        marker.firstMaterial?.diffuse.contents = color

        let markerNode = SCNNode(geometry: marker)
        markerNode.position = SCNVector3(
            Float(position.x) + 0.5,
            0.1,
            Float(position.y) + 0.5
        )

        markerNode.physicsBody = SCNPhysicsBody.static()
        markerNode.physicsBody?.categoryBitMask = (color == .red) ? 4 : 5
        markerNode.physicsBody?.collisionBitMask = 0
        markerNode.physicsBody?.contactTestBitMask = 1

        return markerNode
    }

    private func startAccelerometerUpdates(ballNode: SCNNode, coordinator: Coordinator) { // Moved outside and marked private at struct level
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available.")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: .main) { [weak coordinator] (motionData, error) in
            guard let motionData = motionData, error == nil else { return }
            guard let coordinator = coordinator,
                  let sceneView = coordinator.sceneView,
                  let cameraNode = sceneView.pointOfView else { return }

            let gravity = motionData.gravity
            let gravityVector = SCNVector3(gravity.x, gravity.y, gravity.z)
            let worldGravity = cameraNode.convertVector(gravityVector, to: nil)
            let force = SCNVector3(worldGravity.x, 0, worldGravity.z)
            let forceMultiplier: Float = 25.0
            let adjustedForce = SCNVector3(
                x: force.x * forceMultiplier,
                y: force.y * forceMultiplier,
                z: force.z * forceMultiplier
            )
            ballNode.physicsBody?.applyForce(adjustedForce, asImpulse: false)
        }
    }



    class Coordinator: NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, ObservableObject {
        let parent: Maze3DUIViewRepresentable
        weak var sceneView: SCNView?
        var endMarkerNode: SCNNode?
        var startMarkerNode: SCNNode?
        var hasWon = false
        @Published var dfsPath: [SCNVector3] = []
        @Published var isDFSCompleted = false
        var maze: [[Int]] = []
        var start: (x: Int, y: Int)? = nil
        var end: (x: Int, y: Int)?  = nil

        var ballRollingAudioPlayer: SCNAudioPlayer? // for rolling sound
        var wallCollisionAudioSource: SCNAudioSource? // for collision sound
        var isRollingSoundPlaying = false //track if rolling sound is currently playing
        
               var lastCollisionSoundTime: TimeInterval = 0 // track last collision sound played
               let collisionSoundInterval: TimeInterval = 0.1

        init(_ parent: Maze3DUIViewRepresentable) {
            self.parent = parent
            super.init()

            loadSoundEffects()
        }

                func loadSoundEffects() {
                    if let rollingSoundURL = Bundle.main.url(forResource: "ballRolling", withExtension: "mp3") {
                        let audioSource = SCNAudioSource(url: rollingSoundURL)!
                        audioSource.volume = 0.2
                        audioSource.load()
                        ballRollingAudioPlayer = SCNAudioPlayer(source: audioSource)
                    } else {
                        print("Rolling sound file not found!")
                    }

                    if let collisionSoundURL = Bundle.main.url(forResource: "wallCollision", withExtension: "mp3") {
                        wallCollisionAudioSource = SCNAudioSource(url: collisionSoundURL)!
                        wallCollisionAudioSource?.volume = 0.7
                        wallCollisionAudioSource?.load()
                    } else {
                        print("Wall collision sound file not found!")
                    }
                }


        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let sceneView = self.sceneView,
                  let ballNode = sceneView.scene?.rootNode.childNode(withName: "ballNode", recursively: true),
                  let ballBody = ballNode.physicsBody else { return }

            let velocity = ballBody.velocity
            let speed = sqrt(velocity.x * velocity.x + velocity.z * velocity.z) // 2d speed in xz plane

            let rollingThreshold: Float = 0.1

            if speed > rollingThreshold {
                if !isRollingSoundPlaying {
                    
                    if let player = ballRollingAudioPlayer {
                        ballNode.addAudioPlayer(player)
                        sceneView.scene?.rootNode.runAction(SCNAction.playAudio(player.audioSource!, waitForCompletion: false))
                        isRollingSoundPlaying = true
                    }
                }
            } else {
                if isRollingSoundPlaying {
                    
                    if let player = ballRollingAudioPlayer {
                        ballNode.removeAudioPlayer(player)
                    }
                    isRollingSoundPlaying = false
                }
            }
        }

        func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
                    let nodeA = contact.nodeA
                    let nodeB = contact.nodeB

                    if (nodeA.physicsBody?.categoryBitMask == 1 && nodeB.physicsBody?.categoryBitMask == 2) ||
                        (nodeB.physicsBody?.categoryBitMask == 1 && nodeA.physicsBody?.categoryBitMask == 2) {
                        let ballBody = (nodeA.physicsBody?.categoryBitMask == 1) ? nodeA.physicsBody : nodeB.physicsBody
                        let velocity = ballBody!.velocity
                        let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
                        triggerHapticFeedback(strength: min(speed / 5.0, 1.0))

                        let currentTime = TimeInterval(Date().timeIntervalSinceReferenceDate)
                        if currentTime - lastCollisionSoundTime >= collisionSoundInterval {
                            if let collisionSource = wallCollisionAudioSource {
                                let collisionPlayer = SCNAudioPlayer(source: collisionSource)
                                nodeA.addAudioPlayer(collisionPlayer)
                                nodeA.runAction(SCNAction.playAudio(collisionSource, waitForCompletion: false))
                                lastCollisionSoundTime = currentTime
                            }
                        }
                    }

                    if !hasWon && ((nodeA == endMarkerNode && nodeB.physicsBody?.categoryBitMask == 1) ||
                        (nodeB == endMarkerNode && nodeA.physicsBody?.categoryBitMask == 1)) {
                        hasWon = true
                        DispatchQueue.main.async { [weak self] in
                            self?.showCompletionMessage()
                        }
                    }
                }


        

        func showCompletionMessage() {
            let alert = UIAlertController(title: "Good job!", message: "You've reached the end!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Regenerate Maze", style: .default, handler: { [weak self] _ in
                self?.parent.regenerateMaze = true
                self?.hasWon = false
                self?.clearDFSPath()
            }))

            alert.addAction(UIAlertAction(title: "Exit to Main Menu", style: .destructive, handler: { _ in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
            }))

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController {
                var topController = rootViewController
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alert, animated: true, completion: nil)
            }
        }

        private func triggerHapticFeedback(strength: Float) {
            let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle = strength > 0.7 ? .heavy : (strength > 0.3 ? .medium : .light)
            let generator = UIImpactFeedbackGenerator(style: impactStyle)
            generator.impactOccurred(intensity: CGFloat(strength))
        }

        func solveMaze(in sceneView: SCNView) {
            print("Solve button pressed - solveMaze function called")
            if dfsPath.isEmpty {
                print("dfsPath is empty - calculating new path")
                dfsPath = performDFS(maze: maze)
                print("DFS path calculated - path points count: \(dfsPath.count)")
                drawDFSPath(in: sceneView)
            } else {
                print("dfsPath is NOT empty - clearing existing path")
                clearDFSPath()
                dfsPath = []
            }
        }

        private func clearDFSPath() {
            print("clearDFSPath function called")
            sceneView?.scene?.rootNode.childNodes.forEach { node in
                if node.name == "dfsPathNode" {
                    node.removeFromParentNode()
                }
            }
        }

        private func createWallNode(width: CGFloat, height: CGFloat, thickness: CGFloat) -> SCNNode {
            let wallGeometry = SCNBox(width: width, height: height, length: thickness, chamferRadius: 0)
            wallGeometry.firstMaterial?.diffuse.contents = UIColor.gray
            return SCNNode(geometry: wallGeometry)
        }
        private func performDFS(maze: [[Int]]) -> [SCNVector3] {
            guard let startNode = start else { return [] }
            guard let endNode = end else { return [] }

            var stack: [(x: Int, y: Int)] = [startNode]
            var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: maze[0].count), count: maze.count)
            var cameFrom: [[(x: Int, y: Int)?]] = Array(repeating: Array(repeating: nil, count: maze[0].count), count: maze.count)
            var path: [SCNVector3] = []

            visited[startNode.y][startNode.x] = true

            while !stack.isEmpty {
                guard let current = stack.popLast() else { break }

                if current.x == endNode.x && current.y == endNode.y {
                    var node = endNode
                    path.insert(SCNVector3(Float(endNode.x), 0.1, Float(endNode.y)), at: 0)
                    while let prev = cameFrom[node.y][node.x] {
                        path.insert(SCNVector3(Float(prev.x), 0.1, Float(prev.y)), at: 0)
                        node = prev
                    }
                    return path
                }

                let possibleDirections: [(dx: Int, dy: Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]

                for dir in possibleDirections {
                    let nx = current.x + dir.dx
                    let ny = current.y + dir.dy

                    if nx >= 0 && ny >= 0 && nx < maze[0].count && ny < maze.count &&
                        !visited[ny][nx] && maze[ny][nx] == 0 {

                        visited[ny][nx] = true
                        stack.append( (nx, ny) )
                        cameFrom[ny][nx] = current
                    }
                }
            }
            return []
        }

        private func drawDFSPath(in sceneView: SCNView) {
            print("drawDFSPath function called")
            guard !dfsPath.isEmpty else {
                print("dfsPath is empty - nothing to draw")
                return
            }

            let pathMaterial = SCNMaterial()
            pathMaterial.diffuse.contents = UIColor.green

            for i in 0..<(dfsPath.count - 1) {
                let startPoint = dfsPath[i]
                let endPoint = dfsPath[i + 1]

                print("Segment \(i+1): Start Point = \(startPoint), End Point = \(endPoint)")

                let pathWidth: CGFloat = 0.2
                let pathHeight: CGFloat = 0.2

                let dx = endPoint.x - startPoint.x
                let dz = endPoint.z - startPoint.z
                let distance = CGFloat(sqrt(dx * dx + dz * dz))

                let box = SCNBox(width: distance, height: pathHeight, length: pathWidth, chamferRadius: 0)
                box.firstMaterial = pathMaterial

                let node = SCNNode(geometry: box)
                node.name = "dfsPathNode"

                node.position = SCNVector3((startPoint.x + endPoint.x) / 2, 0.1, (startPoint.z + endPoint.z) / 2)

                let angle = atan2(dz, dx)
                node.eulerAngles = SCNVector3(0, -angle, 0)

                sceneView.scene?.rootNode.addChildNode(node)
            }
        }

        private func distanceBetween(_ start: SCNVector3, _ end: SCNVector3) -> Float {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let dz = end.z - start.z
            return sqrt(dx * dx + dy * dy + dz * dz)
        }

        func startDFS() {
            dfsPath = performDFS(maze: maze)
            isDFSCompleted = true
            if let sceneView = sceneView {
                drawDFSPath(in: sceneView)
            }
        }
    }
}
