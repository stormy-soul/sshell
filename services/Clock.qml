pragma Singleton
import QtQuick

QtObject {
    id: clock

    property var tick: 0 
    readonly property date now: new Date(tick)

    property Timer ticker: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clock.tick = Date.now()
        }
    }
}