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
    
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    onOpacityChanged: {
        if (opacity > 0.1) {
             Audio.refresh()
             Brightness.refresh()
        }
    }

    property string activeDetail: ""
    property bool editMode: false
    
    property var groupExpandedState: ({})
    property var groupedNotifications: []

    function updateGroupedModel() {
        let raw = NotificationService.notifications
        let reversed = raw.slice().reverse()
        
        let groups = {} 
        
        reversed.forEach(n => {
            if (!groups[n.title]) groups[n.title] = []
            groups[n.title].push(n)
        })
        
        let displayList = []
        let processedTitles = {}
        
        reversed.forEach(n => {
            let group = groups[n.title]
            
            if (group.length > (Config.notifications.groupAt || 3)) {
                 if (processedTitles[n.title]) return
                 
                 displayList.push({
                    type: "group",
                    id: "group_" + n.title,
                    title: n.title,
                    items: group,
                    expanded: root.groupExpandedState["group_" + n.title] || false
                })
                processedTitles[n.title] = true
            } else {
                 if (processedTitles[n.title]) return 
                 
                 displayList.push({
                    type: "notification",
                    data: n
                })
            }
        })
        
        root.groupedNotifications = displayList
    }

    // Trigger update when source changes or component completed
    Connections {
        target: NotificationService
        function onNotificationsChanged() { root.updateGroupedModel() }
    }
    Component.onCompleted: {
        opacity = 1
        root.updateGroupedModel()
    }
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
                spacing: Appearance.sizes.padding
                Layout.alignment: Qt.AlignVCenter
                
                Rectangle {
                    id: pfpContainer
                    width: 32
                    height: 32
                    radius: Appearance.sizes.cornerRadiusSmall
                    color: "transparent"
                    clip: true
                    
                    Image {
                        id: pfp
                        anchors.fill: parent
                        source: SystemInfo.profilePicture
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready && Config.controlCenter.showPfp
                        
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: pfp.width
                                height: pfp.height
                                radius: pfpContainer.radius
                                visible: false
                            }
                        }
                    }
                    
                    FluentIcon {
                        visible: pfp.status !== Image.Ready || !Config.controlCenter.showPfp
                        anchors.centerIn: parent
                        icon: "emoji-cat"
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
                    id: notificationList
                    visible: !root.editMode && NotificationService.notifications.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.groupedNotifications
                    spacing: 5
                    
                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                        NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200 }
                    }
                    remove: Transition {
                        NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { property: "scale"; to: 0.9; duration: 200 }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutQuad }
                    }
                    
                    Component {
                        id: notificationComponent
                        Rectangle {
                            width: notificationList.width - 20 
                            height: notificationContent.implicitHeight + 20
                            color: Appearance.colors.background
                            radius: Appearance.sizes.cornerRadius
                            
                            property var notifModel: ({ "title": "", "body": "", "image": "", "id": "" })
                            
                            RowLayout {
                                id: notificationContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12
                                
                                MaterialIcon {
                                    Layout.alignment: Qt.AlignTop
                                    icon: imageIcon.visible ? "notifications" : (notifModel.image || "notifications")
                                    width: 24
                                    height: 24
                                    color: Appearance.colors.accent
                                    visible: !imageIcon.visible
                                }

                                Image {
                                    id: imageIcon
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    Layout.alignment: Qt.AlignTop
                                    visible: notifModel.image && (notifModel.image.startsWith("/") || notifModel.image.startsWith("image://"))
                                    source: visible ? (notifModel.image.startsWith("/") ? "file://" + notifModel.image : notifModel.image) : ""
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle {
                                            width: 24
                                            height: 24
                                            radius: Appearance.sizes.cornerRadiusSmall
                                            visible: false
                                        }
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: notifModel.title
                                        color: Appearance.colors.text
                                        font.family: Appearance.font.family.main
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        font.weight: Font.DemiBold
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: notifModel.body
                                        color: Appearance.colors.textSecondary
                                        font.family: Appearance.font.family.main
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 3
                                    }
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    radius: 10
                                    color: closeMouse.containsMouse ? Appearance.colors.surface : "transparent"
                                    Layout.alignment: Qt.AlignTop
                                    
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "close"
                                        width: 14
                                        height: 14
                                        color: Appearance.colors.textSecondary
                                    }
                                    
                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: NotificationService.close(notifModel.id)
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: groupComponent
                        Column {
                            width: notificationList.width - 20
                            
                            property var groupModel: ({ "title": "", "items": [], "expanded": false, "id": "" })
                            
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: Appearance.colors.surface
                                radius: Appearance.sizes.cornerRadius
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12
                                    
                                    MaterialIcon {
                                        icon: groupModel.expanded ? "expand_less" : "expand_more"
                                        width: 24
                                        height: 24
                                        color: Appearance.colors.text
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Group - " + groupModel.title + " (" + groupModel.items.length + ")"
                                        color: Appearance.colors.text
                                        font.family: Appearance.font.family.main
                                        font.weight: Font.DemiBold
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let newState = !groupModel.expanded
                                        root.groupExpandedState[groupModel.id] = newState
                                        root.updateGroupedModel()
                                    }
                                }
                            }
                            
                            Item {
                                id: expandWrapper
                                width: parent.width
                                height: groupModel.expanded ? expandedContent.height : 0
                                clip: true
                                opacity: groupModel.expanded ? 1 : 0
                                
                                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }

                                Column {
                                    id: expandedContent
                                    width: parent.width
                                    visible: true
                                    spacing: 2
                                    
                                    Repeater {
                                        model: groupModel.items
                                        delegate: Loader {
                                            width: parent.width
                                            sourceComponent: notificationComponent
                                            onLoaded: item.notifModel = modelData
                                        }
                                    }
                                }
                            }
                        }
                    }

                    delegate: Loader {
                        width: ListView.view.width
                        sourceComponent: modelData.type === "group" ? groupComponent : notificationComponent
                        onLoaded: {
                            if (modelData.type === "group") item.groupModel = modelData
                            else item.notifModel = modelData.data
                        }
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
                onMoved: (val) => {
                    Audio.setVolume(val)
                }
            }
            
            SliderRow {
                icon: "brightness_high"
                value: Brightness.brightness
                onMoved: (val) => {
                    Brightness.setBrightness(val)
                }
            }
            
            Item { Layout.fillHeight: true } 
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