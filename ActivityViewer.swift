import SwiftUI

struct ActivityViewer: View {
    let activity: Activity

    var body: some View {
        VStack {
            // Display the activity image or a placeholder
            Image(activity.imageName ?? "placeholder")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300) // Adjust size as needed
                .padding()

            // Display the activity title and description
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
