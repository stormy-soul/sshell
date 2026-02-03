import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../settings"
import "../../services"
import "../common"

ToggleBtn {
    id: root

    property int controlIndex: 0
    readonly property var controlData: QuickControlsService.getControl(controlIndex)
    readonly property string controlId: controlData ? controlData.id : "error"

    expanded: controlData ? controlData.expanded : true

    property bool editMode: false

    Component.onCompleted: {
        console.log("ControlDelegate[" + controlIndex + "]: Created with ID " + controlId)
    }
    
    property var def: QuickControlsService.getDefinition(controlId)
    title: def ? def.title : ""
    icon: def ? def.icon : "" 


    states: [
        State {
            name: "wifi"
            when: controlId === "wifi"
            PropertyChanges {
                target: root
                title: Network.ethernetConnected ? "Ethernet" : "Wi-Fi"
                icon: Network.ethernetConnected ? "account_tree" : (Network.wifiEnabled ? "wifi" : "wifi_off")
                subtitle: Network.ethernetConnected ? "Connected" : (Network.wifiEnabled ? (Network.ssid || "Disconnected") : "Off")
                active: Network.ethernetConnected || Network.wifiEnabled
            }
        },
        State {
            name: "bluetooth"
            when: controlId === "bluetooth"
            PropertyChanges {
                target: root
                icon: Bluetooth.enabled ? "bluetooth" : "bluetooth_disabled"
                subtitle: Bluetooth.connected ? Bluetooth.firstDeviceName : (Bluetooth.enabled ? "On" : "Off")
                active: Bluetooth.enabled
            }
        },
        State {
            name: "audio"
            when: controlId === "audio"
            PropertyChanges {
                target: root
                icon: Audio.muted ? "volume_off" : "volume_up"
                subtitle: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
                active: !Audio.muted
            }
        },
        State {
            name: "nightlight"
            when: controlId === "nightlight"
            PropertyChanges {
                target: root
                subtitle: active ? "On" : "Off"
                active: false 
            }
        },
        State {
            name: "dnd"
            when: controlId === "dnd"
            PropertyChanges {
                target: root
                icon: NotificationService.dnd ? "notifications_off" : "notifications"
                subtitle: active ? "On" : "Off"
                active: NotificationService.dnd
            }
        },
        State {
            name: "airplane"
            when: controlId === "airplane"
            PropertyChanges {
                target: root
                subtitle: active ? "On" : "Off"
                active: false 
            }
        }
    ]

    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    transform: Scale {
        id: scaleTransform
        origin.x: width / 2
        origin.y: height / 2
        xScale: 0
        yScale: 0
    }

    ParallelAnimation {
        running: true
        NumberAnimation {
            target: scaleTransform
            properties: "xScale,yScale"
            from: 0.5
            to: 1.0
            duration: Appearance.animation.duration
            easing.type: Appearance.animation.easingBounce
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: Appearance.animation.duration
        }
    }

    mouseArea.enabled: true 
    mouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    signal detailsRequested()

    mouseArea.onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) {
            if (editMode) {
                 QuickControlsService.remove(controlIndex)
            } else {
                 if (controlId === "wifi") Network.toggleWifi()
                 else if (controlId === "bluetooth") Bluetooth.toggle()
                 else if (controlId === "audio") Audio.toggleMute()
                 else if (controlId === "dnd") NotificationService.toggleDnd()
                 else if (controlId === "active_window") {} // No toggle?
                 else root.clicked()
            }
        } else if (mouse.button === Qt.RightButton) {
            if (editMode) {
                QuickControlsService.toggleSize(controlIndex)
            } else {
                if (controlId === "wifi" || controlId === "bluetooth" || controlId === "audio") {
                    root.detailsRequested()
                }
            }
        }
    }
}