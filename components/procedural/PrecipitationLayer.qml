import QtQuick
import QtQuick.Particles

Item {
    id: root
    anchors.fill: parent
    
    property string condition: "clear"
    property string weatherCode: "" 
    
    visible: condition === "rain" || condition === "snow" || condition === "storm"

    ParticleSystem {
        id: particleSystem
        anchors.fill: parent
        running: root.visible
    }

    readonly property bool isHeavy: {
        if (condition === "storm") return true
        var c = weatherCode
        return ["230", "302", "308", "320", "329", "332", "335", "338", "356", "359", "371", "395"].includes(c)
    }
    
    readonly property bool isHail: {
        var c = weatherCode
        return ["302", "308", "350", "359", "362", "365", "374", "377"].includes(c)
    }

    ImageParticle {
        system: particleSystem
        groups: ["rain"]
        color: root.isHail ? "#DDFFFFFF" : "#AACCCCCC"
        source: "qrc:///particleresources/fuzzydot.png" 
        alpha: root.isHail ? 0.9 : 0.5
    }

    Emitter {
        system: particleSystem
        group: "rain"
        enabled: condition === "rain" || condition === "storm"
        emitRate: (condition === "storm" || root.isHeavy) ? 400 : 150
        lifeSpan: 600
        size: root.isHail ? 6 : 2
        sizeVariation: root.isHail ? 3 : 1
        endSize: 2
        velocity: AngleDirection {
            angle: 90
            angleVariation: 2
            magnitude: 500
            magnitudeVariation: 150
        }
        acceleration: PointDirection { y: 1000 } 
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
    }

    ImageParticle {
        system: particleSystem
        groups: ["snow"]
        color: "#FFFFFF"
        source: "qrc:///particleresources/glowdot.png"
        alpha: 0.8
    }

    Emitter {
        system: particleSystem
        group: "snow"
        enabled: condition === "snow"
        emitRate: 40 
        lifeSpan: 4000
        size: 5
        sizeVariation: 2
        velocity: AngleDirection {
            angle: 90
            angleVariation: 20
            magnitude: 60
            magnitudeVariation: 20
        }
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
    }
}
