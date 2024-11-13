import SwiftUI
import SceneKit

struct Activity1View: View {
    var body: some View {
        SceneKitView()  // Embed SceneKit scene here
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Activity 1")
    }
}

struct Activity1View_Previews: PreviewProvider {
    static var previews: some View {
        Activity1View()
    }
}
