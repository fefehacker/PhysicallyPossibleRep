import SwiftUI

struct ActivityViewer: View {
    let activity: Activity

    var body: some View {
        VStack {
            Image(activity.imageName ?? "placeholder")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding()

            Text(activity.title)
                .font(.title)
                .padding(.bottom, 5)

            Text(activity.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
