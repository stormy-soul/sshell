import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../../settings"
import "../../../../services"
import "../../../common"
import QtMultimedia
import Qt5Compat.GraphicalEffects

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
        left: sourceCenter > 0 ? Math.max(Appearance.sizes.paddingLarge, (sourceCenter - (contentLayout.width / 2))) : Appearance.sizes.paddingLarge
    }
    
    implicitWidth: contentLayout.width + (Appearance.sizes.padding * 3)
    implicitHeight: contentLayout.height + (Appearance.sizes.padding * 3)
    
    property bool shown: false
    visible: shown && sourceCenter > 0 && Weather.data.isValid
    mask: Region {
        item: ShellState.masterVisible ? background : null
    } 
    
    color: "transparent"

    WlrLayershell.namespace: "sshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    readonly property var weatherIconMap: ({
        "113": "clear_day", "116": "partly_cloudy", "119": "cloudy", "122": "cloudy",
        "143": "foggy", "176": "rainy", "179": "rainy", "182": "rainy", "185": "rainy",
        "200": "thunderstorm", "227": "cloudy_snowing", "230": "snowing_heavy",
        "248": "foggy", "260": "foggy", "263": "rainy", "266": "rainy", "281": "rainy",
        "284": "rainy", "293": "rainy", "296": "rainy", "299": "rainy", "302": "weather_hail",
        "305": "rainy", "308": "weather_hail", "311": "rainy", "314": "rainy", "317": "rainy",
        "320": "cloudy_snowing", "323": "cloudy_snowing", "326": "cloudy_snowing",
        "329": "snowing_heavy", "332": "snowing_heavy", "335": "snowing_heavy", "338": "snowing_heavy",
        "350": "rainy", "353": "rainy", "356": "rainy", "359": "weather_hail",
        "362": "rainy", "365": "rainy", "368": "cloudy_snowing", "371": "snowing_heavy",
        "374": "rainy", "377": "rainy", "386": "thunderstorm", "389": "thunderstorm",
        "392": "thunderstorm", "395": "snowing_heavy"
    })
    
    function getIcon(code) {
        if (!code) return "cloud"
        return weatherIconMap[String(code)] || "cloud"
    }
    
    function calculateDaylight() {
        var sunrise = Weather.data.sunrise
        var sunset = Weather.data.sunset
        if (sunrise === "--:--" || sunset === "--:--") return "--"
        
        function parseTime(str) {
            var match = str.match(/(\d+):(\d+)\s*(AM|PM)?/i)
            if (!match) return 0
            var h = parseInt(match[1])
            var m = parseInt(match[2])
            if (match[3]) {
                if (match[3].toUpperCase() === "PM" && h !== 12) h += 12
                if (match[3].toUpperCase() === "AM" && h === 12) h = 0
            }
            return h * 60 + m
        }
        
        var sunriseMin = parseTime(sunrise)
        var sunsetMin = parseTime(sunset)
        var diff = sunsetMin - sunriseMin
        if (diff < 0) diff += 24 * 60
        
        var hours = Math.floor(diff / 60)
        var mins = diff % 60
        return hours + "h " + mins + "m"
    }

    property bool popupHovered: hoverHandler.hovered
    
    HoverHandler {
        id: hoverHandler
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
        
        ColumnLayout {
            id: contentLayout
            anchors.centerIn: parent
            spacing: Appearance.sizes.padding
            width: 280
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: weatherColumn.implicitHeight + (Appearance.sizes.padding * 2)
                color: Appearance.colors.overlayBackground
                radius: Appearance.sizes.cornerRadius
                clip: true

                Item {
                    id: videoContainer
                    anchors.fill: parent
                    visible: true
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: LinearGradient {
                            width: videoContainer.width
                            height: videoContainer.height
                            start: Qt.point(width, 0)
                            end: Qt.point(0, height)
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "white" }
                                GradientStop { position: 0.85; color: "transparent" }
                            }
                            source: Rectangle {
                                width: videoContainer.width
                                height: videoContainer.height
                                radius: Appearance.sizes.cornerRadius
                                color: "black"
                            }
                        }
                    }

                    MediaPlayer {
                        id: player
                        source: root.shown ? "file://" + Directories.assetsPath + "/weather/" + getIcon(Weather.data.iconCode) + ".mp4" : ""
                        audioOutput: AudioOutput { muted: true }
                        videoOutput: videoOut
                        autoPlay: false
                        loops: MediaPlayer.Infinite
                        
                        onSourceChanged: {
                            if (source != "") {
                                play()
                            }
                        }
                    }

                    VideoOutput {
                        id: videoOut
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }
                    
                    FastBlur {
                        anchors.fill: videoOut
                        source: videoOut
                        radius: 12
                    }
                }
                
                ColumnLayout {
                    id: weatherColumn
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.padding
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.sizes.paddingLarge
                        
                        Item {
                            width: 64
                            height: 64
                            
                            MaterialSymbol {
                                anchors.centerIn: parent
                                visible: true
                                text: getIcon(Weather.data.iconCode)
                                size: 48
                                color: Appearance.colors.accent
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Weather.data.condition || "Unknown"
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.large
                                font.weight: Font.Bold
                                color: Appearance.colors.text
                            }
                            
                            Text {
                                text: Config.weather.hideLocation ? Weather.data.tempFeelsLike || "--" : Weather.data.location || Weather.data.city || "Unknown"
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.textSecondary
                                visible: text.length > 0
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sunRow.implicitHeight + (Appearance.sizes.padding * 2)
                        color: Appearance.colors.overlayBackground
                        radius: Appearance.sizes.cornerRadius
                        
                        RowLayout {
                            id: sunRow
                            anchors.fill: parent
                            anchors.margins: Appearance.sizes.padding
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                MaterialIcon {
                                    icon: "wb_sunny"
                                    width: 16
                                    height: 16
                                    color: Appearance.colors.warningCol
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: Weather.data.sunrise
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.text
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignVCenter
                                color: "transparent"
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Repeater {
                                        model: 5
                                        Rectangle {
                                            width: 4
                                            height: 2
                                            radius: 1
                                            color: Appearance.colors.textSecondary
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                text: calculateDaylight()
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.text
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2
                                Layout.alignment: Qt.AlignVCenter
                                color: "transparent"
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Repeater {
                                        model: 5
                                        Rectangle {
                                            width: 4
                                            height: 2
                                            radius: 1
                                            color: Appearance.colors.textSecondary
                                        }
                                    }
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                MaterialIcon {
                                    icon: "wb_twilight"
                                    width: 16
                                    height: 16
                                    color: Appearance.colors.accent
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: Weather.data.sunset
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.text
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: infoColumn.implicitHeight + (Appearance.sizes.padding * 2)
                color: Appearance.colors.overlayBackground
                radius: Appearance.sizes.cornerRadius
                
                ColumnLayout {
                    id: infoColumn
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.padding
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.sizes.padding
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "transparent"
                            radius: Appearance.sizes.cornerRadius
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                MaterialIcon {
                                    icon: "water_drop"
                                    width: Appearance.font.pixelSize.normal
                                    height: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.accent
                                }
                                Text {
                                    text: Weather.data.precipitation + " mm"
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.text
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "transparent"
                            radius: Appearance.sizes.cornerRadius
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                MaterialIcon {
                                    icon: "water"
                                    width: Appearance.font.pixelSize.normal
                                    height: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.accent
                                }
                                Text {
                                    text: Weather.data.humidity + "%"
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.text
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "transparent"
                            radius: Appearance.sizes.cornerRadius
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                MaterialIcon {
                                    icon: "air"
                                    width: Appearance.font.pixelSize.normal
                                    height: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.accent
                                }
                                Text {
                                    text: Weather.data.windSpeed
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.text
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.sizes.padding
                        
                        Repeater {
                            model: Weather.data.forecast
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: forecastCol.implicitHeight + (Appearance.sizes.padding * 2)
                                color: Appearance.colors.surface
                                opacity: modelData.isToday ? 0.8 : 0.6
                                radius: Appearance.sizes.cornerRadius
                                
                                ColumnLayout {
                                    id: forecastCol
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Text {
                                        text: modelData.isToday ? "Today" : modelData.day
                                        font.family: Appearance.font.family.main
                                        font.pixelSize: Appearance.font.pixelSize.tiny
                                        font.weight: modelData.isToday ? Font.Bold : Font.Normal
                                        color: Appearance.colors.text
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    MaterialSymbol {
                                        text: getIcon(modelData.iconCode)
                                        size: 20
                                        color: Appearance.colors.text
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: modelData.high
                                        font.family: Appearance.font.family.main
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Bold
                                        color: Appearance.colors.text
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: modelData.low
                                        font.family: Appearance.font.family.main
                                        font.pixelSize: Appearance.font.pixelSize.tiny
                                        color: Appearance.colors.textSecondary
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
