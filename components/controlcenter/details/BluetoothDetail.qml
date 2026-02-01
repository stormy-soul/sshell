import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import "../../../settings"
import "../../common"

DetailWindow {
    id: root
    title: "Bluetooth"
    
    headerRightItem: Switch {
        checked: root.adapter ? root.adapter.enabled : false
        onToggled: {
            if (root.adapter) root.adapter.enabled = checked
        }
    }
    
    property var adapter: Bluetooth.defaultAdapter
    
    Component.onCompleted: {
        if (adapter && !adapter.discovering) {
            adapter.discovering = true
        }
    }
    
    Component.onDestruction: {
        if (adapter && adapter.discovering) {
            adapter.discovering = false
        }
    }
    
    content: ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10
        
        ProgressBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            indeterminate: true
            visible: root.adapter ? root.adapter.discovering : false
            
            background: Rectangle { 
                 color: Appearance.colors.surfaceVariant
                 radius: 2
            }
            contentItem: Rectangle {
                 color: Appearance.colors.accent
                 radius: 2
            }
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            
            model: root.adapter ? root.adapter.devices.values : []
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                radius: Appearance.sizes.cornerRadius
                color: mouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                
                property var device: modelData
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10
                    
                    MaterialIcon {
                        icon: device.connected ? "bluetooth_connected" : "bluetooth"
                        width: 20
                        height: 20
                        color: device.connected ? Appearance.colors.accent : Appearance.colors.text
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        
                        Text {
                            text: device.name || device.alias || device.address
                            color: device.connected ? Appearance.colors.accent : Appearance.colors.text
                            font.family: Appearance.font.family.main
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: device.connected ? "Connected" : (device.paired ? "Paired" : "")
                            color: Appearance.colors.textSecondary
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            visible: text !== ""
                        }
                    }
                    
                    // Buttons
                    Button {
                        text: device.connected ? "Disconnect" : "Connect"
                        Layout.preferredHeight: 30
                        
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: parent.hovered ? Appearance.colors.colOnPrimary : Appearance.colors.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                        }

                        background: Rectangle {
                            radius: Appearance.sizes.cornerRadius
                            color: parent.hovered ? Appearance.colors.accent : "transparent"
                            border.width: 1
                            border.color: parent.hovered ? Appearance.colors.accent : Appearance.colors.border
                            
                            Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                            Behavior on border.color { ColorAnimation { duration: Appearance.animation.duration } }
                        }

                        onClicked: {
                            if (device.connected) device.disconnect()
                            else device.connect()
                        }
                    }
                }
                
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (device.connected) {
                            device.disconnect()
                        } else {
                            device.connect()
                        }
                    }
                }
            }
            
            Text {
                visible: parent.count === 0
                anchors.centerIn: parent
                text: root.adapter ? "No devices found" : "Bluetooth unavailable"
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
            }
        }
    }
}
