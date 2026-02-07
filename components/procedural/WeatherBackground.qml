import QtQuick
import "../../services"
import ".."
import "../../settings"

Item {
    id: root
    
    property string condition: "clear"
    property string timeOfDay: "day"
    
    function updateState(wmoCode, isDay) {
        root.timeOfDay = isDay ? "day" : "night"
        
        var c = String(wmoCode)
        
        // Clear: 113
        if (c === "113") {
            root.condition = "clear"
            return
        }
        
        // Cloudy: 116, 119, 122
        if (c === "116" || c === "119" || c === "122") {
            root.condition = "cloudy"
            return
        }
        
        // Fog: 143, 248, 260
        if (c === "143" || c === "248" || c === "260") {
            root.condition = "fog"
            return
        }
        
        // Rain: 176, 263, 266, 281-314, 350-377
        if (["176", "263", "266", "293", "296", "299", "302", "305", "308", "311", "314", "317", "320", "350", "353", "356", "359", "362", "365", "374", "377"].includes(c)) {
            root.condition = "rain"
            return
        }
        
        // Snow: 227, 230, 323-338, 368, 371, 395
        if (["227", "230", "323", "326", "329", "332", "335", "338", "368", "371", "395"].includes(c)) {
            root.condition = "snow"
            return
        }
        
        // Storm: 200, 386, 389, 392
        if (["200", "386", "389", "392"].includes(c)) {
            root.condition = "storm"
            return
        }
        
        root.condition = "clear" // Default
    }
    
    
    SkyGradient {
        condition: root.condition
        timeOfDay: root.timeOfDay
        anchors.fill: parent
        z: 0
    }

    StarField {
        condition: root.condition
        timeOfDay: root.timeOfDay
        anchors.fill: parent
        z: 1
    }

    CelestialBody {
        condition: root.condition
        timeOfDay: root.timeOfDay
        anchors.fill: parent
        z: 2
    }

    CloudLayer {
        condition: root.condition
        timeOfDay: root.timeOfDay
        anchors.fill: parent
        z: 3
    }

    PrecipitationLayer {
        condition: root.condition
        weatherCode: String(Weather.data.iconCode)
        anchors.fill: parent
        z: 4
    }

    Rectangle {
        id: lightningFlash
        anchors.fill: parent
        color: '#40ffffff'
        opacity: 0
        z: 6 
        
        SequentialAnimation {
            id: singleFlashAnim
            NumberAnimation { target: lightningFlash; property: "opacity"; to: 0.85; duration: 40; easing.type: Easing.OutQuad }
            NumberAnimation { target: lightningFlash; property: "opacity"; to: 0.0; duration: 120; easing.type: Easing.InQuad }
        }

        function startLightningSequence() {
            var r = Math.random()
            var count = 1
            if (r > 0.4) count = 2
            if (r > 0.8) count = 3
            
            flashIterator.flashesRemaining = count
            flashIterator.interval = 10 
            flashIterator.start()
        }

        Timer {
            id: stormTimer
            interval: 3000
            running: root.condition === "storm"
            repeat: true
            onTriggered: {
                interval = Math.random() * 9000 + 3000
                
                if (Math.random() > 0.3) { 
                   lightningFlash.startLightningSequence()
                }
            }
        }

        Timer {
            id: flashIterator
            property int flashesRemaining: 0
            repeat: false
            
            onTriggered: {
                singleFlashAnim.stop()
                singleFlashAnim.start()
                
                flashesRemaining--
                
                if (flashesRemaining > 0) {
                    interval = Math.random() * 250 + 50
                    start()
                }
            }
        }
    }

    WeatherAtmosphere {
        condition: root.condition
        anchors.fill: parent
        z: 5
    }
}
