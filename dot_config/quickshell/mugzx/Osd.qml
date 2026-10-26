pragma Singleton
import QtQuick
import Quickshell

// On-screen indicator for the volume and brightness keys. Volume changes are
// picked up from PipeWire; mugzx-brightness pings `qs ipc call osd brightness`.
Singleton {
    id: root

    property string kind: ""              // "volume" | "brightness"
    property string screen: ""
    property bool shown: false
    property bool armed: false            // skip the values PipeWire reports at startup

    Timer { interval: 3000; running: true; onTriggered: root.armed = true }
    Timer { id: hideTimer; interval: 1300; onTriggered: root.shown = false }

    // These panels have their own sliders.
    readonly property bool covered: Panels.current === "volume" || Panels.current === "control"

    function show(k) {
        if (!armed || covered)
            return;
        kind = k;
        screen = Panels.focusedScreen();
        shown = true;
        hideTimer.restart();
    }

    function brightness() {
        System.refreshBrightness();
        show("brightness");
    }

    Connections {
        target: Audio
        function onSinkVolumeChanged() { root.show("volume"); }
        function onSinkMutedChanged() { root.show("volume"); }
    }
}
