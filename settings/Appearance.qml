pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    readonly property QtObject sizes: QtObject {
        readonly property int paddingTiny: 2
        readonly property int paddingSmall: 5
        readonly property int padding: 8
        readonly property int paddingLarge: 12
        readonly property int paddingExtraLarge: 16
        readonly property int paddingHellaLarge: 20
        readonly property int paddingMassive: 24
        
        readonly property int cornerRadiusSmall: 6
        readonly property int cornerRadius: 10
        readonly property int cornerRadiusLarge: 14
        readonly property int cornerRadiusHuge: 22
        
        readonly property int barHeight: 40
        readonly property int barMargin: 10
        readonly property int barPadding: 5
        
        readonly property int launcherWidth: 600
        readonly property int launcherInitialHeight: 40
        readonly property int searchBarWidth: 500
        readonly property int searchBarWidthShort: 400
        readonly property int searchBarHeight: 36
        readonly property int searchBarRadius: 22
        readonly property int searchIconSize: 24
        
        readonly property int resultItemHeight: 50
        readonly property int resultIconSize: 32
        readonly property int resultListMaxHeight: 500
        
        readonly property int controlCenterWidth: 400
        
        readonly property int notificationWidth: 350
        readonly property int notificationHeight: 80

        readonly property int mprisPopupWidth: 400
        readonly property int mprisPopupHeight: 165
        
        readonly property int elevationMargin: 8
        readonly property int shadowRadius: 10
    }

    property color m3Background: "#141313"
    property color m3OnBackground: "#DEE2E6"
    property color m3Surface: "#1C1B1B"
    property color m3OnSurface: "#DEE2E6"
    property color m3SurfaceVariant: "#49454F"
    property color m3OnSurfaceVariant: "#CAC4D0"
    property color m3Primary: "#D0BCFF"
    property color m3OnPrimary: "#381E72"
    property color m3PrimaryContainer: "#4F378B"
    property color m3OnPrimaryContainer: "#EADDFF"
    property color m3Secondary: "#CCC2DC"
    property color m3OnSecondary: "#332D41"
    property color m3SecondaryContainer: "#4A4458"
    property color m3OnSecondaryContainer: "#E8DEF8"
    property color m3Tertiary: "#EFB8C8"
    property color m3OnTertiary: "#492532"
    property color m3TertiaryContainer: "#633B48"
    property color m3OnTertiaryContainer: "#FFD8E4"
    property color m3Error: "#F2B8B5"
    property color m3OnError: "#601410"
    property color m3ErrorContainer: "#8C1D18"
    property color m3OnErrorContainer: "#F9DEDC"
    property color m3Outline: "#938F99"
    property color m3OutlineVariant: "#49454F"
    
    property color m3SurfaceContainerHighest: "#36343B"
    property color m3SurfaceContainerHigh: "#2B2930"
    property color m3SurfaceContainer: "#211F26"
    property color m3SurfaceContainerLow: "#1D1B20"
    property color m3SurfaceContainerLowest: "#0F0D13"
    property color m3SurfaceDim: "#141218"
    property color m3SurfaceBright: "#3B383E"

    property color m3InverseSurface: "#E6E1E5"
    property color m3InverseOnSurface: "#313033"
    property color m3InversePrimary: "#6750A4"
    
    property color m3Scrim: "#000000"
    property color m3Shadow: "#000000"
    property color m3SourceColor: "#6750A4"
    
    property bool darkmode: true
    
    property QtObject colors: QtObject {
        property color backgroundSolid: m3Background
        property color background: Qt.rgba(backgroundSolid.r, backgroundSolid.g, backgroundSolid.b, 0.45)
        property color overlayBackground: Qt.rgba(backgroundSolid.r, backgroundSolid.g, backgroundSolid.b, 0.45)
        property color surface: Qt.rgba(m3Surface.r, m3Surface.g, m3Surface.b, 0.9)
        property color surfaceVariant: m3SurfaceVariant
        property color surfaceHover: m3SurfaceContainerHigh
                
        property color text: m3OnSurface
        property color textSecondary: m3OnSurfaceVariant
        property color textDisabled: m3Outline
        
        property color accent: m3Primary
        property color accentHover: m3PrimaryContainer
        property color primary: m3Primary
        property color colOnPrimary: m3OnPrimary
        
        property color highlightBg: Qt.rgba(accent.r, accent.g, accent.b, 0.15)
        property color highlightBgHover: Qt.rgba(accent.r, accent.g, accent.b, 0.25)
        property color highlightBgActive: Qt.rgba(accent.r, accent.g, accent.b, 0.35)
        
        property color iconShapeBg: m3SecondaryContainer
        property color iconShapeFg: m3OnSecondaryContainer
        
        property color border: m3Outline
        property color borderLight: m3OutlineVariant
        property color outline: m3Outline
        
        property color errorCol: m3Error
        property color warningCol: "#f9e2af" 
        property color successCol: "#a6e3a1"
        property color infoCol: m3Secondary
        
        property color shadowCol: "#00000050"
        property color scrimCol: "#00000080"
    }
    
    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string main: Config.theme.mainFont
            readonly property string title: Config.theme.titleFont
            readonly property string monospace: Config.theme.monoFont
            readonly property string iconMaterial: Config.theme.iconFont
            readonly property string nerd: Config.theme.nerdFont
        }
        
        readonly property QtObject pixelSize: QtObject {
            readonly property int teenie: 5
            readonly property int tiny: 10
            readonly property int small: 12
            readonly property int normal: 14
            readonly property int large: 16
            readonly property int extraLarge: 18
            readonly property int huge: 20
            readonly property int massive: 24
            readonly property int jupiter: 48
            readonly property int ton618Ahh: 64
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

    function applyColors(fileContent) {
        if (!fileContent) return;
        
        try {
            const json = JSON.parse(fileContent)
            const colors = json.colors || json
            
            for (const key in colors) {
                if (colors.hasOwnProperty(key)) {
                    let colorValue = colors[key]
                    if (typeof colorValue === 'object' && colorValue !== null) {
                         colorValue = colorValue.default || colorValue.dark || colorValue.light || "#FF0000"
                    }

                    let camelCase = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
                    camelCase = camelCase.charAt(0).toUpperCase() + camelCase.slice(1)
                    
                    const m3Key = `m3${camelCase}`
                    
                    if (root.hasOwnProperty(m3Key)) {
                        root[m3Key] = colorValue
                    }
                }
            }
            
            if (json.is_dark_mode !== undefined) {
                root.darkmode = json.is_dark_mode
            }
            console.log("Appearance: Applied colors from theme file.")
            
        } catch (e) {
            console.error("Appearance: Failed to parse theme:", e)
        }
    }

    FileView { 
        id: themeFileView
        path: Directories.generatedMaterialThemePath
        watchChanges: true
        
        onLoaded: {
            const fileContent = themeFileView.text
            var txt = ""
             if (typeof themeFileView.text === "function") {
                txt = themeFileView.text();
            } else {
                txt = themeFileView.text;
            }
            root.applyColors(txt)
        }

        onFileChanged: {
            reloadTimer.restart()
        }
    }
    
    Timer {
        id: reloadTimer
        interval: 100 
        repeat: false
        onTriggered: themeFileView.reload()
    }
    
    Component.onCompleted: {
        themeFileView.reload()
    }
}