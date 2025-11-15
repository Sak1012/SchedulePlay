import AppKit
import Foundation

@MainActor
final class StatusItemViewModel: ObservableObject {
    enum DisplayState: Equatable {
        case loading
        case idle
        case event(CalendarEventInfo)
        case music(MusicTrackInfo)
        case eventAndMusic(CalendarEventInfo, MusicTrackInfo)
        case error(String)
    }

    enum MenuLabelContent: Equatable {
        case icon
        case text(String)
    }

    @Published private(set) var displayState: DisplayState = .loading {
        didSet { handleStateChange() }
    }
    @Published private(set) var lastRefreshDate: Date?
    @Published private(set) var menuLabelContent: MenuLabelContent = .text("Updating…")

    private let eventService = EventService()
    private let musicService = MusicService()
    private var refreshTimer: Timer?
    private var labelRotationTimer: Timer?
    private var showingEventLabel = true
    private let labelCharacterLimit = 15

    init() {
        handleStateChange()
        scheduleRefreshTimer()
        Task { await refreshNow() }
    }

    deinit {
        refreshTimer?.invalidate()
        labelRotationTimer?.invalidate()
    }

    func refreshNow() async {
        lastRefreshDate = Date()

        do {
            let event = try await eventService.upcomingEventWithinNextThirtyMinutes()
            let track = musicService.currentTrack()
            applyState(event: event, track: track)
        } catch {
            applyErrorState(from: error)
        }
    }

    private func applyState(event: CalendarEventInfo?, track: MusicTrackInfo?) {
        if let event, let track {
            displayState = .eventAndMusic(event, track)
        } else if let event {
            displayState = .event(event)
        } else if let track {
            displayState = .music(track)
        } else {
            displayState = .idle
        }
    }

    private func applyErrorState(from error: Error) {
        displayState = .error(error.localizedDescription)
    }

    private func scheduleRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.refreshNow() }
        }
    }

    private func handleStateChange() {
        configureLabelRotation(for: displayState)
        updateMenuLabel(for: displayState)
    }

    private func configureLabelRotation(for state: DisplayState) {
        labelRotationTimer?.invalidate()

        if case .eventAndMusic = state {
            showingEventLabel = true
            labelRotationTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.showingEventLabel.toggle()
                self.updateMenuLabel(for: self.displayState)
            }
        } else {
            showingEventLabel = false
        }
    }

    private func updateMenuLabel(for state: DisplayState) {
        switch state {
        case .loading:
            menuLabelContent = .text("Updating…")
        case .idle:
            menuLabelContent = .icon
        case .event(let info):
            menuLabelContent = .text(truncatedLabel(for: info.title))
        case .music(let track):
            menuLabelContent = .text(truncatedLabel(for: track.name))
        case .eventAndMusic(let event, let track):
            let value = showingEventLabel ? event.title : track.name
            menuLabelContent = .text(truncatedLabel(for: value))
        case .error:
            menuLabelContent = .text("Check access")
        }
    }

    private func truncatedLabel(for text: String) -> String {
        guard text.count > labelCharacterLimit else { return text }
        let prefixText = String(text.prefix(labelCharacterLimit))
        return "\(prefixText)…"
    }
}
