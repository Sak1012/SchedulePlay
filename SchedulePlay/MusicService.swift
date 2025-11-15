import AppKit
import Foundation

struct MusicTrackInfo: Equatable {
    let name: String
    let artist: String?

    var fullDescription: String {
        guard let artist, !artist.isEmpty else { return name }
        return "\(name) – \(artist)"
    }
}

struct MusicService {
    private static let delimiter = "|||"

    func currentTrack() -> MusicTrackInfo? {
        guard let script = NSAppleScript(source: Self.script) else { return nil }

        var errorDictionary: NSDictionary?
        let output = script.executeAndReturnError(&errorDictionary)

        if errorDictionary != nil {
            return nil
        }

        guard let rawValue = output.stringValue, !rawValue.isEmpty else { return nil }
        let components = rawValue.components(separatedBy: Self.delimiter)
        guard let name = components.first, !name.isEmpty else { return nil }
        let artistComponent = components.dropFirst().first
        let artist = artistComponent?.isEmpty == false ? artistComponent : nil
        return MusicTrackInfo(name: name, artist: artist)
    }

    private static let script = """
    if application "Music" is running then
        tell application "Music"
            if player state is playing then
                set trackName to name of current track
                set artistName to ""
                if artist of current track is not missing value then
                    set artistName to artist of current track
                end if
                return trackName & "\(delimiter)" & artistName
            else
                return ""
            end if
        end tell
    else
        return ""
    end if
    """
}
