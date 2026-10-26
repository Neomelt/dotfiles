pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which popup panel is open and on which screen. Only one is open at a time.
Singleton {
    id: root

    readonly property var names: ["volume", "wifi", "power", "control", "calendar", "media"]

    property string current: ""
    property string screen: ""

    function focusedScreen() {
        if (Hyprland.focusedMonitor)
            return Hyprland.focusedMonitor.name;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    function open(name, screenName) {
        if (names.indexOf(name) < 0)
            return;
        root.screen = screenName || focusedScreen();
        root.current = name;
    }

    function close() {
        root.current = "";
    }

    function toggle(name, screenName) {
        const s = screenName || focusedScreen();
        if (root.current === name && root.screen === s)
            close();
        else
            open(name, s);
    }

    function isOpen(name, screenName) {
        return root.current === name && root.screen === screenName;
    }
}
