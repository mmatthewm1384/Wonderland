import SwiftUI

extension Color {
    static let wlBackground = Color(red: 5/255, green: 7/255, blue: 10/255)
    static let wlCyan = Color(red: 0/255, green: 229/255, blue: 255/255)
    static let wlPurple = Color(red: 112/255, green: 0/255, blue: 255/255)
    static let wlGreen = Color(red: 0/255, green: 255/255, blue: 102/255)
}

struct TemporalEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let text: String
    let branch: String?
}

@MainActor
final class TemporalVM: ObservableObject {
    @Published var currentTime = Date()
    @Published var events: [TemporalEvent] = [
        TemporalEvent(timestamp: Date(), text: "Reality Anchor — You are here now", branch: nil)
    ]

    func travelYears(_ years: Int) {
        currentTime = Calendar.current.date(byAdding: .year, value: years, to: currentTime) ?? currentTime
        events.append(
            TemporalEvent(timestamp: currentTime, text: "Time jump \(years)y", branch: nil)
        )
    }

    func log(_ text: String) {
        events.append(
            TemporalEvent(timestamp: Date(), text: text, branch: nil)
        )
    }

    func branch(_ name: String) {
        events.append(
            TemporalEvent(timestamp: currentTime, text: "Branch created", branch: name)
        )
    }
}

@main
struct WonderlandTimeTravelApp: App {
    var body: some Scene {
        WindowGroup {
            WonderlandTimeTravelView()
        }
    }
}

struct WonderlandTimeTravelView: View {
    @StateObject private var vm = TemporalVM()
    @State private var eventText = ""
    @State private var branchName = ""

    var body: some View {
        ZStack {
            Color.wlBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                Text("TEMPORAL CORE")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.wlCyan)

                Text(vm.currentTime.formatted(date: .complete, time: .standard))
                    .foregroundStyle(Color.wlGreen)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.events) { event in
                            TimelineRow(event: event)
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Log reality event", text: $eventText)
                        .textFieldStyle(.roundedBorder)

                    Button("Log") {
                        guard !eventText.isEmpty else { return }
                        vm.log(eventText)
                        eventText = ""
                    }
                    .tint(Color.wlGreen)
                }

                HStack {
                    TextField("Branch name", text: $branchName)
                        .textFieldStyle(.roundedBorder)

                    Button("Branch") {
                        guard !branchName.isEmpty else { return }
                        vm.branch(branchName)
                        branchName = ""
                    }
                    .tint(Color.wlPurple)
                }

                HStack {
                    Button("Travel +1y") { vm.travelYears(1) }
                    Button("Travel -1y") { vm.travelYears(-1) }
                }
                .tint(Color.wlCyan)
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .preferredColorScheme(.dark)
    }
}

struct TimelineRow: View {
    let event: TemporalEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(event.branch == nil ? Color.wlCyan : Color.wlPurple)
                .frame(width: 10, height: 10)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))

                Text(event.branch == nil ? event.text : "\(event.text): \(event.branch!)")
                    .foregroundStyle(.white)
            }
        }
    }
}
