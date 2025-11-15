# SchedulePlay

SchedulePlay is a lightweight SwiftUI macOS menu bar app that reminds you about the next calendar event within the next 30 minutes. Whenever the next 30 minutes are clear, it shows the title of the current Apple Music track instead.

## Features
- Runs as a background agent (`LSUIElement`) and lives exclusively in the menu bar.
- Polls EventKit every minute and requests calendar permission on first launch.
- Shows the event title, time range, countdown and quick link to open Calendar when something is imminent.
- Falls back to the current Apple Music song via AppleScript when there are no imminent events.

## Getting started
1. Open `SchedulePlay.xcodeproj` in Xcode 15 or newer.
2. Select the `SchedulePlay` scheme and a "My Mac" destination.
3. Update the signing team or bundle identifier if needed.
4. Build & run. The first launch requests calendar access and Apple Music scripting access.
5. The status text automatically refreshes every minute; use the menu's Refresh button to update immediately.

## Permissions
- **Calendars** (`NSCalendarsUsageDescription`): required to read upcoming events.
- **Apple Events** (`NSAppleEventsUsageDescription`): required to query Apple Music for the now playing track.

Grant both prompts on first launch so the countdown and fallback music text can update.
