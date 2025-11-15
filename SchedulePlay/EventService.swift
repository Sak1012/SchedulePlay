import EventKit
import Foundation

struct CalendarEventInfo: Equatable, Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let calendarTitle: String
    let meetingURL: URL?

    init(event: EKEvent) {
        id = event.eventIdentifier ?? UUID().uuidString
        title = event.title ?? "Untitled"
        let start = event.startDate ?? event.endDate ?? Date()
        let end = event.endDate ?? event.startDate ?? start
        startDate = start
        endDate = end
        location = event.location
        calendarTitle = event.calendar.title
        meetingURL = event.url ?? CalendarEventInfo.firstURL(in: event.location) ?? CalendarEventInfo.firstURL(in: event.notes)
    }

    var menuTitle: String {
        let time = CalendarEventInfo.timeFormatter.string(from: startDate)
        return "\(title) \(time)"
    }

    var timeRangeDescription: String {
        let start = CalendarEventInfo.timeFormatter.string(from: startDate)
        let end = CalendarEventInfo.timeFormatter.string(from: endDate)
        return "\(start) – \(end)"
    }

    var relativeDescription: String {
        CalendarEventInfo.relativeFormatter.localizedString(for: startDate, relativeTo: Date())
    }

    var countdownSummary: String {
        guard startDate > Date() else { return "Now" }
        return CalendarEventInfo.countdownFormatter.string(from: Date(), to: startDate) ?? "Soon"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    private static let countdownFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        formatter.maximumUnitCount = 1
        return formatter
    }()

    private static let linkDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

    private static func firstURL(in text: String?) -> URL? {
        guard let text, !text.isEmpty else { return nil }
        guard let detector = linkDetector else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return detector.firstMatch(in: text, options: [], range: range)?.url
    }
}

enum EventServiceError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar permission is required."
        }
    }
}

actor EventService {
    private let store = EKEventStore()

    func upcomingEventWithinNextThirtyMinutes() async throws -> CalendarEventInfo? {
        try await ensureAccess()
        return nextEvent(within: 30 * 60)
    }

    private func ensureAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized, .fullAccess:
            return
        case .notDetermined:
            let granted = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                store.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    continuation.resume(returning: granted)
                }
            }

            guard granted else {
                throw EventServiceError.accessDenied
            }
        case .denied, .restricted, .writeOnly:
            throw EventServiceError.accessDenied
        @unknown default:
            throw EventServiceError.accessDenied
        }
    }

    private func nextEvent(within interval: TimeInterval) -> CalendarEventInfo? {
        let start = Date()
        let end = start.addingTimeInterval(interval)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { lhs, rhs in
                lhs.startDate < rhs.startDate
            }

        guard let event = events.first else { return nil }
        return CalendarEventInfo(event: event)
    }
}
