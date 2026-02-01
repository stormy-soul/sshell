import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../settings"
import "../../services"
import "../common"
import "../notifications"

Rectangle {
    id: root
    implicitWidth: Config.controlCenter.width
    implicitHeight: Screen.height - Appearance.sizes.barHeight - (Appearance.sizes.barMargin * 2)

    color: Appearance.colors.overlayBackground
    radius: Appearance.sizes.cornerRadiusLarge
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
    clip: true
    
    opacity: 0
    visible: true 
    
    Component.onCompleted: opacity = 1
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    onOpacityChanged: {
        if (opacity > 0.1) {
             Audio.refresh()
             Brightness.refresh()
        }
    }

    property string activeDetail: ""
    property bool editMode: false
    
    Item {
        id: mainContent
        anchors.fill: parent
        
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingExtraLarge
        spacing: Appearance.sizes.padding
        
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 5
            spacing: Appearance.sizes.paddingSmall
            
            Row {
                id: userRow
                spacing: Appearance.sizes.paddingSmall
                Layout.alignment: Qt.AlignVCenter
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "transparent"
                    clip: true
                    
                    Image {
                        id: pfp
                        anchors.fill: parent
                        source: SystemInfo.profilePicture
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready
                    }
                    
                    MaterialIcon {
                        visible: pfp.status !== Image.Ready
                        anchors.centerIn: parent
                        icon: "person"
                        width: 24
                        height: 24
                        color: Appearance.colors.text
                    }
                }
                
                Text {
                    text: SystemInfo.userName + "@" + SystemInfo.hostName
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
                        { icon: root.editMode ? "check" : "add", cmd: () => root.editMode = !root.editMode },
                        { icon: "settings", cmd: "gnome-control-center" }, 
                        { icon: "sync", cmd: () => Quickshell.reload(true) },
                        { icon: "power_settings_new", cmd: "wlogout" }
                    ]
                    
                    Rectangle {
                        width: 40
                        height: 40
                        radius: Appearance.sizes.cornerRadius
                        color: btnMouse.containsMouse ? Appearance.colors.overlayBackground : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: modelData.icon
                            width: 20
                            height: 20
                            color: Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof modelData.cmd === "function") {
                                    modelData.cmd()
                                } else if (modelData.cmd) {
                                     Quickshell.execDetached(modelData.cmd)
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
            
            columns: 4
            columnSpacing: Appearance.sizes.padding
            rowSpacing: Appearance.sizes.padding
            
            Repeater {
                model: QuickControlsService.activeControls.length
                delegate: ControlDelegate {
                    editMode: root.editMode
                    onDetailsRequested: root.activeDetail = controlId
                }
            }
        }
        
        Text {
            visible: root.editMode
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Left click to add/remove • Right click to resize"
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.small
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 73
            
            color: Appearance.colors.overlayBackground
            radius: Appearance.sizes.cornerRadiusLarge
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Appearance.sizes.padding
                spacing: 5
                
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !root.editMode && NotificationService.notifications.length === 0
                    
                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "notifications_paused"
                        width: Appearance.font.pixelSize.ton618Ahh
                        height: Appearance.font.pixelSize.ton618Ahh
                        color: Appearance.colors.textDisabled
                    }
                }
                
                GridView {
                    visible: root.editMode
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: width / 4
                    cellHeight: 80
                    
                    model: QuickControlsService.availableControls
                    delegate: Item {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight
                        
                        property bool isAdded: QuickControlsService.findIndex(modelData.id) !== -1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            opacity: isAdded ? 0.5 : 1.0
                            
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: Appearance.sizes.cornerRadius
                                color: Appearance.colors.surfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                                
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: modelData.icon
                                    width: 20
                                    height: 20
                                    color: Appearance.colors.text
                                }
                            }
                            
                            Text {
                                text: modelData.title
                                color: Appearance.colors.text
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: isAdded ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (!parent.isAdded) {
                                    QuickControlsService.add(modelData.id)
                                }
                            }
                        }
                    }
                }

                ListView {
                    visible: !root.editMode && NotificationService.notifications.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: NotificationService.notifications
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: Appearance.colors.background
                        radius: Appearance.sizes.cornerRadius
                        
                        Text { text: modelData.title; color: Appearance.colors.text; x: 10; y: 10 }
                        Text { text: modelData.body; color: Appearance.colors.textSecondary; x: 10; y: 30 }
                    }
                }
                
                RowLayout {
                    visible: !root.editMode
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: NotificationService.notifications.length + " Notifications"
                        color: Appearance.colors.textSecondary
                        font.family: Appearance.font.family.main
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 30 
                        height: 30 
                        radius: 15
                        color: clearMouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "close" 
                            width: 20
                            height: 20
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
                        width: 30
                        height: 30
                        radius: Appearance.sizes.cornerRadius
                        color: dndMouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: NotificationService.dnd ? "notifications_off" : "notifications"
                            width: 20
                            height: 20
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
                icon: "brightness_high"
                value: Brightness.brightness
                onMoved: (val) => Brightness.setBrightness(val)
            }
            
            Item { Layout.fillHeight: true } 
        }
    }
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "transparent"
        visible: root.activeDetail !== ""
        z: 999
        
        
        Rectangle {
            anchors.fill: parent
            color: Appearance.colors.overlayBackground
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.activeDetail = ""
        }
        
        Loader {
            anchors.centerIn: parent
            width: parent.width - (Appearance.sizes.paddingExtraLarge * 2)
            height: parent.height * 0.5
            
            source: {
                if (root.activeDetail === "wifi") return "./details/WifiDetail.qml"
                if (root.activeDetail === "bluetooth") return "./details/BluetoothDetail.qml"
                if (root.activeDetail === "audio") return "./details/AudioDetail.qml"
                return ""
            }
            
            onLoaded: {
                if (item) {
                     item.backRequested.connect(() => root.activeDetail = "")
                }
            }
        }
    }
    
    component SliderRow: RowLayout {
        id: root
        property string icon
        property real value
        signal moved(real val)
        
        Layout.fillWidth: true
        spacing: 10
        
        MaterialIcon {
            icon: root.icon
            width: Appearance.font.pixelSize.small
            height: Appearance.font.pixelSize.small
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