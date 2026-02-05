// Based on https://git.outfoxxed.me/outfoxxed/nixnew & https://github.com/end-4/dots-hyprland 's implementation

pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../settings"

Singleton {
    id: root
    
    property list<MprisPlayer> players: Mpris.players.values.filter(player => isRealPlayer(player))
    
    property MprisPlayer trackedPlayer: null
    property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null
        
    signal trackChanged(reverse: bool)
    property bool __reverse: false
    property real trackStartOffset: 0
    
    property var activeTrack: ({})

    property bool hasPlasmaIntegration: false
    
    Process {
        id: plasmaIntegrationAvailabilityCheckProc
        running: true
        command: ["bash", "-c", "command -v plasma-browser-integration-host"]
        onExited: (exitCode, exitStatus) => {
            root.hasPlasmaIntegration = (exitCode === 0)
        }
    }

    function isRealPlayer(player) {
        if (Config.mpris.ignore) {
            for (var i = 0; i < Config.mpris.ignore.length; i++) {
                var ignoreId = Config.mpris.ignore[i]
                if (player.dbusName.indexOf(ignoreId) !== -1 || player.identity.indexOf(ignoreId) !== -1) {
                    return false
                }
            }
        }
        
        const isSystem = (
            player.dbusName.startsWith('org.mpris.MediaPlayer2.playerctld') ||
            (player.dbusName.endsWith('.mpd') && !player.dbusName.endsWith('MediaPlayer2.mpd'))
        )
        
        return !isSystem
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (root.trackedPlayer == null || modelData.isPlaying) {
                    root.trackedPlayer = modelData
                }
            }

            Component.onDestruction: {
                if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
                    for (const player of Mpris.players.values) {
                        if (player.playbackState === MprisPlaybackState.Playing) {
                            root.trackedPlayer = player
                            break
                        }
                    }

                    if (trackedPlayer == null && Mpris.players.values.length != 0) {
                        trackedPlayer = Mpris.players.values[0]
                    }
                }
            }

            function onPlaybackStateChanged() {
                if (modelData.playbackState === MprisPlaybackState.Playing) {
                    root.trackedPlayer = modelData
                }
            }
        }
    }

    onActivePlayerChanged: {
        root.trackStartOffset = 0
        root.updateTrack()
    }
    

    
    Connections {
        target: activePlayer
        ignoreUnknownSignals: true

        function onTrackTitleChanged() { 
            if (!root.activePlayer.trackTitle) return
            
            root.trackStartOffset = root.activePlayer.position
            root.updateTrack() 
        }
        function onTrackArtistChanged() { root.updateTrack() }
        function onTrackAlbumChanged() { root.updateTrack() }
        function onTrackArtUrlChanged() { root.updateTrack() }
        
        function onPositionChanged() {
             if (root.activePlayer.position < root.trackStartOffset && root.trackStartOffset > 0) {
                 root.trackStartOffset = 0
                 root.updateTrack()
             }
        }
    }

    function updateTrack() {
        if (!activePlayer) {
             root.activeTrack = {}
             return
        }

        var rawLen = root.activePlayer.length || 1
        var scale = (rawLen > 1000000) ? 0.000001 : 1.0
        var normLen = rawLen * scale

        root.activeTrack = {
            uniqueId: root.activePlayer.identity,
            artUrl: root.activePlayer.trackArtUrl ?? "",
            title: root.activePlayer.trackTitle || "Unknown Title",
            artist: root.activePlayer.trackArtist || "Unknown Artist",
            album: root.activePlayer.trackAlbum || "Unknown Album",
            length: normLen,
            length: normLen,
            timeScale: scale,
            startOffset: root.trackStartOffset
        }
        
        root.trackChanged(__reverse)
        root.__reverse = false
    }

    property bool isPlaying: root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing
    
    function togglePlaying() {
        if (root.activePlayer && root.activePlayer.canTogglePlaying) {
            root.activePlayer.togglePlaying()
        }
    }
    
    function next() {
        if (root.activePlayer && root.activePlayer.canGoNext) {
            root.activePlayer.next()
        }
    }
    
    function previous() {
        if (root.activePlayer && root.activePlayer.canGoPrevious) {
            root.activePlayer.previous()
        }
    }
}
