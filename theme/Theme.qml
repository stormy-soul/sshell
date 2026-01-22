pragma Singleton
import QtQuick

import "../services"

QtObject {
    id: theme

    property color accent: Config.theme.accentColor || "#a6e3a1"
    property color background: "#1e1e2e"
    property color surface: "#313244"
    property color surfaceVariant: "#45475a"
    property color text: "#cdd6f4"
    property color textSecondary: "#a6adc8"
    property color border: "#585b70"

    property int paddingTiny: 2
    property int paddingSmall: 5
    property int padding: 10
    property int paddingLarge: 15
    property int paddingMassive: 20
    property int gap: 10

    property int cornerRadius: Config.theme.cornerRadius || 10
    property int cornerRadiusSmall: 5

    property int fontSizeSmall: 10
    property int fontSize: 13
    property int fontSizeLarge: 15
    property int fontSizeMassive: 20
    property string fontFamily: "CaskaydiaCove Nerd Font"

    property int animationDuration: Config.theme.animationDuration || 200
    property int animationDurationFast: 100

    property real shadowOpacity: 0.3
    property int shadowRadius: 10

    Component.onCompleted: {
        loadMatugenColors();
    }

    function loadMatugenColors() {
        // TODO: Load from Matugen generated file
        // Example: ~/.config/matugen/colors.json
    }
}