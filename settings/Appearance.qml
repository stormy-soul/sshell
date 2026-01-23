pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    
    readonly property QtObject sizes: QtObject {
        readonly property int paddingTiny: 2
        readonly property int paddingSmall: 5
        readonly property int padding: 8
        readonly property int paddingLarge: 12
        readonly property int paddingExtraLarge: 16
        
        readonly property int cornerRadiusSmall: 6
        readonly property int cornerRadius: 10
        readonly property int cornerRadiusLarge: 14
        
        readonly property int barHeight: 40
        readonly property int barMargin: 10
        readonly property int barPadding: 5
        
        readonly property int launcherWidth: 600
        readonly property int launcherInitialHeight: 32
        readonly property int searchBarWidth: 400
        readonly property int searchBarHeight: 40
        readonly property int searchBarRadius: 22
        readonly property int searchIconSize: 24
        
        readonly property int resultItemHeight: 56
        readonly property int resultIconSize: 32
        readonly property int resultListMaxHeight: 400
        
        readonly property int controlCenterWidth: 400
        
        readonly property int notificationWidth: 350
        readonly property int notificationHeight: 80
        
        readonly property int elevationMargin: 8
        readonly property int shadowRadius: 10
    }
    
    readonly property QtObject colors: QtObject {
        readonly property color background: "#1e1e2e"
        readonly property color surface: "#313244"
        readonly property color surfaceVariant: "#45475a"
        readonly property color surfaceHover: "#3a3d4d"
        
        // Input field background (darker than surface)
        readonly property color inputBackground: "#252536"
        
        readonly property color text: "#cdd6f4"
        readonly property color textSecondary: "#a6adc8"
        readonly property color textDisabled: "#6c7086"
        
        readonly property color accent: "#89b4fa"
        readonly property color accentHover: '#698bc0'
        readonly property color primary: "#89b4fa"
        readonly property color colOnPrimary: '#1e1e20'
        
        // Accent-based highlight colors for selections/hover
        readonly property color highlightBg: Qt.rgba(accent.r, accent.g, accent.b, 0.15)
        readonly property color highlightBgHover: Qt.rgba(accent.r, accent.g, accent.b, 0.25)
        readonly property color highlightBgActive: Qt.rgba(accent.r, accent.g, accent.b, 0.35)
        
        // Search icon shape background
        readonly property color iconShapeBg: Qt.rgba(accent.r, accent.g, accent.b, 0.2)
        readonly property color iconShapeFg: accent
        
        readonly property color border: "#585b70"
        readonly property color borderLight: "#6c7086"
        readonly property color outline: "#7f849c"
        
        readonly property color errorCol: "#f38ba8"
        readonly property color warningCol: "#f9e2af"
        readonly property color successCol: "#a6e3a1"
        readonly property color infoCol: "#89b4fa"
        
        readonly property color shadowCol: "#00000050"
        readonly property color scrimCol: "#00000080"
    }
    
    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string main: nerd
            readonly property string title: "Inter"
            readonly property string monospace: "JetBrains Mono"
            readonly property string iconMaterial: "Material Symbols Rounded"
            readonly property string nerd: "CaskaydiaCove Nerd Font"
        }
        
        readonly property QtObject pixelSize: QtObject {
            readonly property int tiny: 10
            readonly property int small: 12
            readonly property int normal: 14
            readonly property int large: 16
            readonly property int huge: 20
            readonly property int massive: 24
        }
        
        readonly property QtObject weight: QtObject {
            readonly property int light: Font.Light
            readonly property int normal: Font.Normal
            readonly property int medium: Font.Medium
            readonly property int bold: Font.Bold
        }
    }
    
    readonly property QtObject animation: QtObject {
        readonly property int durationFast: 100
        readonly property int duration: 200
        readonly property int durationSlow: 300
        readonly property int durationVerySlow: 500
        
        readonly property int easingDefault: Easing.OutCubic
        readonly property int easingSharp: Easing.OutQuad
        readonly property int easingSmooth: Easing.InOutCubic
        readonly property int easingBounce: Easing.OutBack
        
        readonly property var bezierEmphasized: [0.2, 0.0, 0, 1.0, 1, 1]
        readonly property var bezierStandard: [0.4, 0.0, 0.2, 1.0, 1, 1]
    }
}
