import SwiftUI

struct ActivityCardView: View {
    let activity: Activity
    @Binding var selectedActivity: Activity?

    var body: some View {
        VStack {
            if let imageName = activity.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 350)
                    .overlay(
                        Text("image not found")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }

            Text(activity.title)
                .font(.headline)
                .padding(.top, 10)

            Text(activity.description)
                .font(.subheadline)
                .padding(.top, 5)
                .padding(.bottom, 10)


        }
        .padding()
        .background(Color(.sRGB, red: 0.163, green: 0.163, blue: 0.163, opacity: 0.5))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
