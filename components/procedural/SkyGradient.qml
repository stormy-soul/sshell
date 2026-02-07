import QtQuick
import "../../settings"

Rectangle {
    id: root
    anchors.fill: parent
    
    property string timeOfDay: "day"
    property string condition: "clear"
    
    gradient: Gradient {
        GradientStop { 
            position: 0.0
            color: getTopColor()
            Behavior on color { ColorAnimation { duration: 1000 } }
        }
        GradientStop { 
            position: 1.0
            color: getBottomColor()
            Behavior on color { ColorAnimation { duration: 1000 } }
        }
    }
    
    function getTopColor() {
        // Night Handling
        if (timeOfDay === "night") {
            if (condition === "clear") return "#0B1026" // Deep navy
            if (condition === "cloudy") return "#151720" // Dark grey-blue
            if (condition === "rain") return "#0F111A" // Darker storm
            if (condition === "storm") return "#08090D" // Almost black
            if (condition === "snow") return "#1B1D24" // Cold dark grey
            if (condition === "fog") return "#181A20" // Muted dark
            return "#0B1026"
        }
        
        // Day Handling
        if (condition === "clear") return "#4A90E2" // Bright friendly blue
        if (condition === "cloudy") return "#6B7C8E" // Muted grey-blue
        if (condition === "rain") return "#425569" // Darker slate
        if (condition === "storm") return "#2C3E50" // Deep ominous blue
        if (condition === "snow") return "#8CA6BF" // Cold pale blue
        if (condition === "fog") return "#7F8C8D" // Flat grey
        
        return "#4A90E2"
    }

    function getBottomColor() {
        // Night Handling
        if (timeOfDay === "night") {
            if (condition === "clear") return "#1B2438" // Slightly lighter navy
            if (condition === "cloudy") return "#232630"
            if (condition === "rain") return "#1A1D25"
            if (condition === "storm") return "#111318"
            if (condition === "snow") return "#252830"
            if (condition === "fog") return "#202329"
            return "#1B2438"
        }
        
        // Day Handling
        if (condition === "clear") return "#8AC3F2" // Light sky blue
        if (condition === "cloudy") return "#95A5A6" // Greyish
        if (condition === "rain") return "#607D8B" // Blue grey
        if (condition === "storm") return "#34495E" // Dark slate
        if (condition === "snow") return "#DDEBF7" // Very light cool white
        if (condition === "fog") return "#BDC3C7" // Light fog grey
        
        return "#8AC3F2"
    }
}
