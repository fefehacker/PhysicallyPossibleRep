import SwiftUI

struct MainMenuView: View {
    let activities: [Activity] = [
        Activity(title: "Maze Game", description: "Navigate through the maze", imageName: "placeholder", isMazeGame: true),
        Activity(title: "Other Activity", description: "Some other activity", imageName: "otherImage", isMazeGame: false)
    ]
    
    @State private var selectedActivity: Activity? = nil
    @State private var isBouncingButton1 = false
    @State private var isBouncingButton2 = false
    @State private var showSettings = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Title at the top
                    Text("Main Menu")
                        .font(.largeTitle)
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Carousel of activity cards
                    TabView {
                        ForEach(activities) { activity in
                            ActivityCardView(activity: activity, selectedActivity: $selectedActivity)
                                .onTapGesture {
                                    selectedActivity = activity
                                    print("Selected Activity: \(activity.title)")
                                }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 500)

                    // Buttons section with animated icons
                    HStack {
                        Button(action: {
                            // Action for the button
                            showSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")  // Icon
                                    .font(.title)  // Adjust icon size
                                Text("Settings")  // Text next to the icon
                                    .font(.headline)  // Adjust text size
                            }
                            .padding()  // Padding around the text and icon
                            .background(Color.blue)  // Background color
                            .foregroundColor(.white)  // Text and icon color
                            .cornerRadius(20)  // Rounded corners
                        }

                            .onAppear {
                                isBouncingButton1 = false  // This ensures that the button animates
                            }
                            .padding(.trailing)

                        
                        .padding(.leading)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()  // Ensure this view exists
                    }

                    .padding(.bottom, 20)

                    Spacer()
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color.black : Color.white,
                            Color.purple
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                )
                .fullScreenCover(item: $selectedActivity) { activity in
                    VStack {
                        ActivityDetailView(activity: activity)
                        
                        Button("Close") {
                            selectedActivity = nil
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 30)
                    }
                }

            }
        }
    }
}
