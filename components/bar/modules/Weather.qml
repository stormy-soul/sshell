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
        "113": "wb_sunny", // clear_day -> wb_sunny
        "116": "partly_cloudy_day",
        "119": "cloud",
        "122": "cloud",
        "143": "foggy", // fog?
        "176": "rainy", // grain? or water_drop? rainy is usually "weather_rainy" or just "rainy"
        "179": "rainy",
        "182": "rainy",
        "185": "rainy",
        "200": "thunderstorm",
        "227": "cloudy_snowing",
        "230": "snowing", // snowing_heavy
        "248": "foggy",
        "260": "foggy",
        "263": "rainy",
        "266": "rainy",
        "281": "rainy",
        "284": "rainy",
        "293": "rainy",
        "296": "rainy",
        "299": "rainy",
        "302": "weather_hail", // hail?
        "305": "rainy",
        "308": "weather_hail",
        "311": "rainy",
        "314": "rainy",
        "317": "rainy",
        "320": "cloudy_snowing",
        "323": "cloudy_snowing",
        "326": "cloudy_snowing",
        "329": "snowing", // snowing_heavy
        "332": "snowing",
        "335": "snowing",
        "338": "snowing",
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
            var name = root.weatherIconMap[c]
            if (name === "clear_day") return "wb_sunny"
            return name
        } 
        return "cloud" // Default
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.padding
        
        MaterialSymbol {
            text: getIcon(Services.Weather.data.iconCode)
            size: Appearance.font.pixelSize.large
            color: Appearance.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: Services.Weather.data.temp
            color: Appearance.colors.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.small
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
