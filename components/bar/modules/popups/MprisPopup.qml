import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../../../settings"
import "../../../../services"
import "../../../common"

PanelWindow {
    id: root
    
    property string position: Config.bar.position || "bottom"
    property Item sourceItem: null
    property real sourceCenter: {
        if (!sourceItem || sourceItem.width <= 0) return -1
        var mapped = sourceItem.mapToGlobal(sourceItem.width/2, 0)
        return mapped.x > 0 ? mapped.x : -1
    }
    
    anchors {
        bottom: position === "bottom"
        top: position === "top"
        left: true 
    }
    
    margins {
        bottom: position === "bottom" ? Appearance.sizes.barMargin : 0
        top: position === "top" ? Appearance.sizes.barMargin : 0
        left: sourceCenter > 0 ? Math.max(Appearance.sizes.paddingLarge, (sourceCenter - (implicitWidth / 2))) : Appearance.sizes.paddingLarge
    }
    
    implicitWidth: Appearance.sizes.mprisPopupWidth
    implicitHeight: Appearance.sizes.mprisPopupHeight
    
    property bool shown: false
    visible: shown && sourceCenter > 0 && MprisController.activePlayer
    mask: Region {
        item: ShellState.masterVisible ? background : null
    } 
    
    color: "transparent"

    WlrLayershell.namespace: "sshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    property bool popupHovered: hoverHandler.hovered
    
    HoverHandler {
        id: hoverHandler
    }
    
    Timer {
        running: root.visible && MprisController.isPlaying
        interval: 1000
        repeat: true
        onTriggered: {
            if (MprisController.activePlayer) {
                MprisController.activePlayer.positionChanged()
            }
        }
    }
    
    function getClampedPosition() {
        var scale = MprisController.activeTrack.timeScale || 1.0
        var offset = MprisController.activeTrack.startOffset || 0
        
        var rawPos = MprisController.activePlayer?.position || 0
        var effectivePos = rawPos - offset
        var pos = effectivePos * scale
        
        var len = MprisController.activeTrack.length || 1
        return Math.max(0, Math.min(pos, len))
    }
    
    function getTrackLength() {
        return MprisController.activeTrack.length || 1
    }
    
    function formatTime(seconds) {
        var totalLen = getTrackLength()
        var showHours = totalLen >= 3600
        
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = Math.floor(seconds % 60)
        
        if (showHours) {
             return h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
        } else {
             return m + ":" + (s < 10 ? "0" : "") + s
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Appearance.sizes.cornerRadiusLarge
        color: Appearance.colors.overlayBackground
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
        
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }
        
        Image {
            id: bgImage
            anchors.fill: parent
            source: MprisController.activeTrack.artUrl || ""
            fillMode: Image.PreserveAspectCrop
            
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 64
                blur: 1.0
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
            visible: bgImage.status === Image.Ready
        }
        
        RowLayout {
            id: contentLayout
            anchors.centerIn: parent
            width: parent.width - (Appearance.sizes.paddingLarge * 2)
            spacing: Appearance.sizes.paddingLarge
            
            Rectangle {
                id: coverContainer
                Layout.preferredWidth: 140
                Layout.preferredHeight: 140
                Layout.alignment: Qt.AlignVCenter
                radius: Appearance.sizes.cornerRadiusLarge
                color: Appearance.colors.surfaceVariant
                
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: coverContainer.width
                        height: coverContainer.height
                        radius: coverContainer.radius
                    }
                }
                
                Image {
                    id: coverArt
                    anchors.fill: parent
                    source: MprisController.activeTrack.artUrl || ""
                    fillMode: Image.PreserveAspectCrop
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: Appearance.sizes.cornerRadiusLarge
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }
                
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "music_note"
                    width: 40
                    height: 40
                    color: Appearance.colors.textSecondary
                    visible: coverArt.status !== Image.Ready
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Appearance.sizes.paddingSmall
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.sizes.paddingSmall
                    
                    Text {
                        text: MprisController.activeTrack.title || "Unknown Title"
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.huge
                        font.weight: Font.Bold
                        color: Appearance.colors.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        maximumLineCount: 1
                    }

                    Loader {
                        id: visualizerLoader
                        active: Config.mpris.popupVisualizer
                        sourceComponent: Component {
                            AudioVisualizer {
                                onBar: false
                                maxBarHeight: 20
                                minBarHeight: 4
                                barWidth: 3
                                barGap: 2
                                animationDuration: 15
                                source: MprisController.activeTrack.artUrl || ""
                            }
                        }
                    }
                }

                Text {
                    text: MprisController.activeTrack.artist || "Unknown Artist"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    maximumLineCount: 1
                }
                
                // Item { Layout.fillHeight: true }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: formatTime(root.getClampedPosition())
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: formatTime(root.getTrackLength())
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                        }
                    }
                    
                    Rectangle {
                        id: sliderContainer
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Appearance.colors.surfaceVariant
                        
                        Rectangle {
                            id: sliderProgress
                            width: {
                                var pos = root.getClampedPosition()
                                var len = root.getTrackLength()
                                var ratio = len > 0 ? (pos / len) : 0
                                return parent.width * Math.max(0, Math.min(1, ratio))
                            }
                            height: parent.height
                            radius: 3
                            color: Appearance.colors.textSecondary
                        }
                        
                        Rectangle {
                            x: sliderProgress.width - (width / 2)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 7
                            color: Appearance.colors.textSecondary
                            visible: sliderMa.containsMouse || sliderMa.pressed
                        }
                        
                        MouseArea {
                            id: sliderMa
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onPressed: (mouse) => {
                                if (MprisController.activePlayer?.canSeek) {
                                    var ratio = Math.max(0, Math.min(1, mouse.x / sliderContainer.width))
                                    MprisController.activePlayer.position = ratio * MprisController.activePlayer.length
                                }
                            }
                            
                            onPositionChanged: (mouse) => {
                                if (pressed && MprisController.activePlayer?.canSeek) {
                                    var ratio = Math.max(0, Math.min(1, mouse.x / sliderContainer.width))
                                    MprisController.activePlayer.position = ratio * MprisController.activePlayer.length
                                }
                            }
                        }
                    }
                }
                   
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Appearance.sizes.padding
                    
                    Rectangle {
                        width: 48
                        height: 48
                        radius: width / 2
                        color: "transparent"
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "skip_previous"
                            width: 32
                            height: 32
                            color: Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: prevMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisController.previous()
                        }
                    }
                    
                    Rectangle {
                        width: 56
                        height: 56
                        radius: width / 2
                        color: "transparent"
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: MprisController.isPlaying ? "pause" : "play_arrow"
                            width: 36
                            height: 36
                            color: Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: playMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisController.togglePlaying()
                        }
                    }
                    
                    Rectangle {
                        width: 48
                        height: 48
                        radius: width / 2
                        color: "transparent"
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "skip_next"
                            width: 32
                            height: 32
                            color: Appearance.colors.text
                        }
                        
                        MouseArea {
                            id: nextMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisController.next()
                        }
                    }
                }
            }
        }
    }
}
