import QtQuick
import QtQuick.Layouts
import "../../settings"
import "../../services"
import "../common"
import "../notifications"

Rectangle {
    id: root
    
    color: Appearance.colors.overlayBackground
    radius: Appearance.sizes.cornerRadius
    border.width: 1
    border.color: Appearance.colors.border
    clip: true
    
    opacity: 0
    visible: true 
    
    Component.onCompleted: opacity = 1
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingExtraLarge
        spacing: Appearance.sizes.padding
        
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 5
            spacing: 10
            
            Row {
                id: userRow
                spacing: 10
                Layout.alignment: Qt.AlignVCenter
                
                MaterialSymbol {
                    text: "account_circle"
                    size: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "User" 
                    color: Appearance.colors.text
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.large 
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Item { Layout.fillWidth: true } 
            
            Row {
                Layout.fillHeight: true
                spacing: 10
                
                Repeater {
                    model: [
                        { icon: "settings", cmd: "gnome-control-center" }, 
                        { icon: "refresh", cmd: "hyprctl dispatch reload" },
                        { icon: "power_settings_new", cmd: "wlogout" }
                    ]
                    
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: btnMouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: modelData.icon
                            size: 20
                        }
                        
                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.cmd) {
                                     Quickshell.exec(modelData.cmd)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 12
            
            columns: 2
            columnSpacing: Appearance.sizes.padding
            rowSpacing: Appearance.sizes.padding
            
            ToggleBtn {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                icon: Network.wifiEnabled ? "wifi" : "wifi_off"
                title: "Wi-Fi"
                subtitle: Network.ssid || "Disconnected"
                active: Network.wifiEnabled
                onClicked: Network.toggleWifi()
            }
            
            ToggleBtn {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                icon: Bluetooth.enabled ? "bluetooth" : "bluetooth_disabled"
                title: "Bluetooth"
                subtitle: Bluetooth.connected ? Bluetooth.firstDeviceName : (Bluetooth.enabled ? "On" : "Off")
                active: Bluetooth.enabled
                onClicked: Bluetooth.toggle()
            }
            
            ToggleBtn {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                icon: Audio.muted ? "volume_off" : "volume_up"
                title: "Audio"
                subtitle: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
                active: !Audio.muted
                onClicked: Audio.toggleMute()
            }
            
            ToggleBtn {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                icon: "nightlight"
                title: "Night Light"
                subtitle: active ? "On" : "Off"
                active: false
                onClicked: {}
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 73
            
            color: Appearance.colors.surface
            radius: Appearance.sizes.cornerRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Appearance.sizes.padding
                spacing: 5
                
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: NotificationService.notifications.length === 0
                    
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "notifications_paused"
                        size: 64
                        color: Appearance.colors.textDisabled
                    }
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: NotificationService.notifications
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: Appearance.colors.background
                        radius: Appearance.sizes.cornerRadiusSmall
                        
                        Text { text: modelData.title; color: Appearance.colors.text; x: 10; y: 10 }
                        Text { text: modelData.body; color: Appearance.colors.textSecondary; x: 10; y: 30 }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: NotificationService.notifications.length + " Notifications"
                        color: Appearance.colors.textSecondary
                        font.family: Appearance.font.family.main
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: clearMouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                        
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "delete"
                            size: 20
                            color: Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.notifications = []
                        }
                    }
                    
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: dndMouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                        
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: NotificationService.dnd ? "notifications_off" : "notifications"
                            size: 20
                            color: NotificationService.dnd ? Appearance.colors.accent : Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: dndMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.toggleDnd()
                        }
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 10
            spacing: 10
            
            Item { Layout.fillHeight: true } 
            
            SliderRow {
                icon: Audio.muted ? "volume_off" : "volume_up"
                value: Audio.volume
                onMoved: (val) => Audio.setVolume(val)
            }
            
            SliderRow {
                icon: "brightness_6"
                value: Brightness.brightness
                onMoved: (val) => Brightness.setBrightness(val)
            }
            
            Item { Layout.fillHeight: true } 
        }
    }
    
    component ToggleBtn: Rectangle {
        property string icon
        property string title
        property string subtitle
        property bool active
        signal clicked()
        
        radius: Appearance.sizes.cornerRadius
        color: Appearance.colors.surface
        
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            spacing: 12
            
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignVCenter
                radius: 12 
                color: active ? Appearance.colors.accent : Appearance.colors.surfaceVariant
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: icon
                    size: 20
                    color: active ? Appearance.colors.colOnPrimary : Appearance.colors.text
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0
                
                Text {
                    text: title
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Appearance.colors.text
                    font.family: Appearance.font.family.main
                    font.weight: Font.Bold
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                
                Text {
                    text: subtitle
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Appearance.colors.textSecondary
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
    
    component SliderRow: RowLayout {
        property string icon
        property real value
        signal moved(real val)
        
        Layout.fillWidth: true
        spacing: 10
        
        MaterialSymbol {
            text: icon
            size: 20
            color: Appearance.colors.text
        }
        
        Slider {
            id: control
            Layout.fillWidth: true
            from: 0
            to: 1
            value: parent.value
            onMoved: parent.moved(value)
        }
    }
}