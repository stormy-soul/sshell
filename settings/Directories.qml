pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root
    
    readonly property string projectRoot: Quickshell.env("PWD") || Quickshell.env("HOME") + "/Documents/Projects/sshell"
    readonly property string assetsPath: Quickshell.shellPath("assets")
    readonly property string iconsPath: assetsPath + "/material-design-icons/svg"
    readonly property string weatherIconsPath: assetsPath + "/weather-icons/production"
    
    readonly property string home: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")
    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || (home + "/.local/share")
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME") || (home + "/.cache")
    readonly property string cliphistDecode: cacheHome + "/sshell/cliphist"
    readonly property string state: dataHome + "/sshell/state"
    
    readonly property string cacheDir: home + "/.cache/sshell"
    readonly property string thumbDir: cacheDir + "/thumbs"
    readonly property string configFile: cacheDir + "/wallpaper_config.json"

    readonly property var appDirs: [
        "/usr/share/applications",
        dataHome + "/applications"
    ]
    
    readonly property var systemIconDirs: [
        "/usr/share/icons/hicolor/scalable/apps/",
        "/usr/share/icons/hicolor/256x256/apps/",
        "/usr/share/icons/hicolor/128x128/apps/",
        "/usr/share/icons/hicolor/48x48/apps/",
        "/usr/share/pixmaps/"
    ]
    
    function getMaterialIcon(iconName, iconType) {
        return iconsPath + "/" + iconType + "/" + iconName + ".svg"
    }
    
    function getMaterialIconUrl(iconName, iconType) {
        return "file://" + getMaterialIcon(iconName, iconType)
    }
    
    function getWeatherIconUrl(code, isDay, style) {
        // WMO Code Mapping
        var iconName = "not-available"
        var c = String(code)
        
        if (c === "113" || c === "0") iconName = isDay ? "clear-day" : "clear-night"
        
        // 116: Partly Cloudy
        else if (c === "116" || c === "1" || c === "2") iconName = isDay ? "partly-cloudy-day" : "partly-cloudy-night"
        
        // 119: Cloudy, 122: Overcast, 3: Overcast
        else if (c === "119" || c === "122" || c === "3") iconName = "overcast"
        
        // 143: Mist, 248: Fog, 260: Freezing Fog, 45, 48
        else if (c === "143" || c === "248" || c === "260" || c === "45" || c === "48") iconName = isDay ? "fog-day" : "fog-night"
        
        // 176: Patchy rain possible, 263: Patchy light drizzle, 266: Light drizzle, 293: Patchy light rain
        // 51, 53, 55 (Drizzle), 61, 63, 65 (Rain) -> mapped to Drizzle/Rain variants
        else if (["176", "263", "266", "293", "296", "299", "305", "308", "311", "314", "353", "51", "53", "55", "61", "80", "81", "82"].includes(c)) {
             iconName = isDay ? "partly-cloudy-day-rain" : "partly-cloudy-night-rain"
        }
        
        // Heavy Rain: 281, 284, 302, 356, 359, 63, 65
        else if (["281", "284", "302", "356", "359", "63", "65"].includes(c)) iconName = "rain"
        
        // Snow/Sleet: 179, 182, 185, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371
        else if (["179", "227", "323", "326", "368", "71", "85", "86"].includes(c)) {
             iconName = isDay ? "partly-cloudy-day-snow" : "partly-cloudy-night-snow"
        }
        else if (["230", "329", "332", "335", "338", "371", "73", "75"].includes(c)) iconName = "snow"
        
        // Sleet: 182, 185, 281, 284, 311, 314, 317, 350, 362, 365, 374, 377, 66, 67
        else if (["182", "185", "281", "284", "317", "350", "362", "365", "374", "377", "66", "67"].includes(c)) iconName = "sleet"
        
        // Thunder: 200, 386, 389, 392, 395, 95, 96, 99
        else if (["200", "386", "389", "392", "95"].includes(c)) iconName = "thunderstorms"
        else if (["395", "96", "99"].includes(c)) iconName = "thunderstorms-rain"
        
        // Ice pellets? Hail?
        else if (c === "77") iconName = "hail"
        
        // Fallback checks
        if (iconName === "not-available") {
            console.log("WeatherIconDebug: Unmapped code " + c + ", returning empty to trigger fallback.")
            return ""
        }
        
        var folderName = style
        if (style === "filled") folderName = "fill"
        
        var url = "file://" + weatherIconsPath + "/" + folderName + "/svg/" + iconName + ".svg"
        console.log("WeatherIconDebug: code=" + code + " (" + c + "), isDay=" + isDay + ", style=" + style + " -> " + url)
        return url
    }
    
    Component.onCompleted: {
        console.log("Directories: Assets path:", assetsPath)
        console.log("Directories: Icons path:", iconsPath)
    }
}
