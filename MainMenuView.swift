import SwiftUI

struct MainMenuView: View {
    
    let activities: [Activity] = [
        Activity(title: "Maze Game", description: "Navigate through the maze", imageName: "placeholder", isMazeGame: true),
        Activity(title: "Space Maze", description: "The ultimate maze challenge!", imageName: "otherImage", isMazeGame: false)
    ]
    
    @State private var selectedActivity: Activity? = nil
    @State private var isBouncingButton1 = false
    @State private var isBouncingButton2 = false
    @State private var showSettings = false
    @State var gameSettings = GameSettings()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // title at the top
                    Text("Main Menu")
                        .font(.largeTitle)
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // carousel of activity cards
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
                    
                    // buttons section with animated icons
                    HStack {
                        Button(action: {
                            showSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")  // icon
                                    .font(.title)     // adjust icon size
                                Text("Settings")      // text next to the icon
                                    .font(.headline)     // adjust text size
                            }
                            .padding()  // padding around the text and icon
                            .background(Color.blue)  // background color
                            .foregroundColor(.white)  // text and icon color
                            .cornerRadius(20)  // rounded corners
                        }
                        .onAppear {
                            isBouncingButton1 = false //was making the button bounce but decided not to use this
                        }
                        .padding(.trailing)
                        .padding(.leading)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView(gameSettings: $gameSettings)
                    }
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
                NavigationView {
                    VStack {
                        ActivityDetailView(activity: activity, gameSettings: $gameSettings)
                        
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
