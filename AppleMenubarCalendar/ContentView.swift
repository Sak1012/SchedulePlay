import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: StatusItemViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Divider()

            Spacer(minLength: 0)

            bottomBar
        }
        .padding(16)
        .frame(minWidth: 320, minHeight: 240)
    }

    @ViewBuilder
    private var header: some View {
        switch model.displayState {
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                Text("Loading schedule…")
            }
        case .event(let info):
            eventSection(info)
        case .music(let track):
            musicSection(track)
        case .eventAndMusic(let info, let track):
            VStack(alignment: .leading, spacing: 12) {
                eventSection(info)
                Divider()
                musicSection(track)
            }
        case .idle:
            VStack(alignment: .leading, spacing: 8) {
                Label("Nothing scheduled", systemImage: "calendar")
                    .font(.headline)
                Text("We will fall back to Apple Music once something plays.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: 8) {
                Label("Permission needed", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                Text(message)
                    .font(.callout)
            }
        }
    }

    @ViewBuilder
    private func eventSection(_ info: CalendarEventInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                openInCalendar(info)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text(info.title)
                            .font(.headline)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                    }

                    Text("Starts \(info.countdownSummary.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(info.timeRangeDescription)
                        .font(.callout)

                    if let location = info.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.callout)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let meetingURL = info.meetingURL {
                Button("Join") {
                    openMeetingLink(meetingURL)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    @ViewBuilder
    private func musicSection(_ track: MusicTrackInfo) -> some View {
        Button {
            openMusicApp()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Label("Now Playing", systemImage: "music.note")
                    .font(.headline)
                Text(track.fullDescription)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func openInCalendar(_ event: CalendarEventInfo) {
        NSWorkspace.shared.launchApplication("Calendar")
    }

    private func openMeetingLink(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    private func openMusicApp() {
        NSWorkspace.shared.launchApplication("Music")
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            Button("Refresh") {
                Task { await model.refreshNow() }
            }

            Spacer()

            if let date = model.lastRefreshDate {
                Text("Updated at \(date, style: .time)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Updated at --")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

}
