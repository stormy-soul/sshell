import QtQuick
import "../../../settings"
import "../../../services" as Services
import "../../common"

Rectangle {
    id: root
    
    implicitHeight: 30
    implicitWidth: row.implicitWidth
    color: "transparent"
    
    readonly property var weatherIconMap: ({
        "113": "wb_sunny", 
        "116": "partly_cloudy_day",
        "119": "cloud",
        "122": "cloud",
        "143": "foggy", 
        "176": "water_drop", 
        "179": "water_drop",
        "182": "water_drop",
        "185": "water_drop",
        "200": "thunderstorm",
        "227": "weather_snowy",
        "230": "weather_snowy", 
        "248": "foggy",
        "260": "foggy",
        "263": "water_drop",
        "266": "water_drop",
        "281": "water_drop",
        "284": "water_drop",
        "293": "water_drop",
        "296": "water_drop",
        "299": "water_drop",
        "302": "weather_hail", 
        "305": "water_drop",
        "308": "weather_hail",
        "311": "water_drop",
        "314": "water_drop",
        "317": "water_drop",
        "320": "weather_snowy",
        "323": "weather_snowy",
        "326": "weather_snowy",
        "329": "weather_snowy", 
        "332": "weather_snowy",
        "335": "weather_snowy",
        "338": "weather_snowy",
        "350": "water_drop",
        "353": "water_drop",
        "356": "water_drop",
        "359": "weather_hail",
        "362": "water_drop",
        "365": "water_drop",
        "368": "weather_snowy",
        "371": "weather_snowy",
        "374": "water_drop",
        "377": "water_drop",
        "386": "thunderstorm",
        "389": "thunderstorm",
        "392": "thunderstorm",
        "395": "weather_snowy"
    })

    function getIcon(code) {
        if (!code) return "question_mark"
        var c = String(code)
        if (root.weatherIconMap[c]) {
            return root.weatherIconMap[c]
        } 
        return "cloud" // Default
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.padding
        
        MaterialIcon {
            icon: getIcon(Services.Weather.data.iconCode)
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: Appearance.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: Services.Weather.data.temp
            color: Appearance.colors.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
             Services.Weather.getData()
        }
    }
}
