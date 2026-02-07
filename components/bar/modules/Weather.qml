import QtQuick
import QtQuick.Layouts

import "../../../settings"
import "../../../services" as Services
import "../../common"
import "../modules/popups"

Rectangle {
    id: root
    
    implicitHeight: Config.bar.height
    implicitWidth: row.implicitWidth
    color: "transparent"
    
    property bool hovered: mouseArea.containsMouse
    property bool shouldShowPopup: root.hovered || popup.popupHovered
    
    Timer {
        id: closeDelayTimer
        interval: 150
        onTriggered: {
            if (!root.shouldShowPopup) {
                popup.shown = false
            }
        }
    }
    
    onShouldShowPopupChanged: {
        if (shouldShowPopup) {
            closeDelayTimer.stop()
            popup.shown = true
        } else {
            closeDelayTimer.restart()
        }
    }
    
    readonly property var weatherIconMap: ({
        "113": "clear_day",
        "116": "partly_cloudy_day",
        "119": "cloud",
        "122": "cloud",
        "143": "foggy",
        "176": "rainy",
        "179": "rainy",
        "182": "rainy",
        "185": "rainy",
        "200": "thunderstorm",
        "227": "cloudy_snowing",
        "230": "snowing_heavy",
        "248": "foggy",
        "260": "foggy",
        "263": "rainy",
        "266": "rainy",
        "281": "rainy",
        "284": "rainy",
        "293": "rainy",
        "296": "rainy",
        "299": "rainy",
        "302": "weather_hail",
        "305": "rainy",
        "308": "weather_hail",
        "311": "rainy",
        "314": "rainy",
        "317": "rainy",
        "320": "cloudy_snowing",
        "323": "cloudy_snowing",
        "326": "cloudy_snowing",
        "329": "snowing_heavy",
        "332": "snowing_heavy",
        "335": "snowing",
        "338": "snowing_heavy",
        "350": "rainy",
        "353": "rainy",
        "356": "rainy",
        "359": "weather_hail",
        "362": "rainy",
        "365": "rainy",
        "368": "cloudy_snowing",
        "371": "snowing",
        "374": "rainy",
        "377": "rainy",
        "386": "thunderstorm",
        "389": "thunderstorm",
        "392": "thunderstorm",
        "395": "snowing"
    })

    function getIcon(code) {
        if (!code) return "question_mark"
        var c = String(code)
        if (root.weatherIconMap[c]) {
            return root.weatherIconMap[c]
        } 
        return "cloud"
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.sizes.padding
        
        MaterialSymbol {
            text: getIcon(Services.Weather.data.iconCode)
            size: Appearance.font.pixelSize.large
            color: Appearance.colors.text
            Layout.alignment: Qt.AlignVCenter
        }
        
        Text {
            text: Services.Weather.data.temp
            color: Appearance.colors.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        
        onClicked: (mouse) => {
             Services.Weather.getData()
             
             if (mouse.button === Qt.RightButton) {
                 Services.NotificationService.push(
                    "Weather", 
                    "Manually fetching weather data",
                    "wb_cloudy"
                 )
             }
        }
    }
    
    WeatherPopup {
        id: popup
        sourceItem: root
    }
}
