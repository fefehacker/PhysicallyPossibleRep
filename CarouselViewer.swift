import SwiftUI

struct CarouselViewer: View {
    let activities: [Activity]

    var body: some View {
        NavigationView {
            TabView {
                ForEach(activities) { activity in
                    ActivityViewer(activity: activity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}
