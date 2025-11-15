# SchedulePlay

Hey there! SchedulePlay is my tiny helper for keeping life in sync: I wanted a single glanceable place to see what I'm listening to **and** whether something is about to start on my calendar, without juggling separate widgets or apps. The result is a lightweight SwiftUI macOS menu bar app that reminds you about the next calendar event within the next 30 minutes, and when the schedule is clear it shows the aktuell Apple Music track instead.

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

## Using the included build
If you'd rather skip Xcode, there's a ready-made build in `SchedulePlay/SchedulePlay.app`:
1. In Finder, open this repository and locate the `SchedulePlay/SchedulePlay.app` bundle.
2. Drag it into `/Applications` (or anywhere else) and double-click to launch.
3. The app still asks for calendar + Apple Events permissions on first launch; grant both so the menu bar status can update.
4. Optionally keep a copy elsewhere as a backup—it's the same bundle Xcode would export via “Copy App”.

## Permissions
- **Calendars** (`NSCalendarsUsageDescription`): required to read upcoming events.
- **Apple Events** (`NSAppleEventsUsageDescription`): required to query Apple Music for the now playing track.

Grant both prompts on first launch so the countdown and fallback music text can update.
