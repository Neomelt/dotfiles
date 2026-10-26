import QtQuick
import Quickshell
import Quickshell.Wayland

// The volume / brightness pill above the dock. Click-through, and on the
// overlay layer so it also shows over fullscreen video.
PanelWindow {
    id: win

    required property var shellScreen

    readonly property bool active: Osd.shown && Osd.screen === shellScreen.name
    readonly property bool isVolume: Osd.kind !== "brightness"
    readonly property real value: isVolume ? Audio.sinkVolume : System.brightness
    readonly property bool muted: isVolume && Audio.sinkMuted
    readonly property int pad: 16
    readonly property int pillWidth: 250
    property bool mapped: false

    onActiveChanged: {
        if (active) {
            mapped = true;
            unmapTimer.stop();
        } else {
            unmapTimer.restart();
        }
    }

    Timer {
        id: unmapTimer
        interval: Theme.anim + 40
        onTriggered: win.mapped = false
    }

    screen: shellScreen
    visible: active || mapped
    color: "transparent"
    anchors.bottom: true
    exclusionMode: ExclusionMode.Ignore
    margins.bottom: 60 + 6 + 14 - pad          // just above the dock
    implicitWidth: pillWidth + 2 * pad
    implicitHeight: 44 + 2 * pad

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "mugzx-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    Surface {
        x: win.pad
        y: win.pad
        width: win.pillWidth
        height: 44
        radius: 22
        opacity: win.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }

        transform: Translate {
            y: win.active ? 0 : 8
            Behavior on y { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        }

        Icon {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            size: 16
            name: !win.isVolume ? "sun"
                : win.muted || win.value === 0 ? "volume-x"
                : win.value < 0.5 ? "volume-low" : "volume"
            color: win.muted ? Theme.textFaint : Theme.text
        }

        Rectangle {
            id: track
            anchors.left: icon.right
            anchors.leftMargin: 12
            anchors.right: label.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            radius: 2
            color: Theme.track

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, win.value))
                height: parent.height
                radius: 2
                color: win.muted ? Theme.textFaint : Theme.accent
                Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            id: label
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            horizontalAlignment: Text.AlignRight
            text: win.muted ? "静音" : Math.round(win.value * 100) + "%"
            color: win.muted ? Theme.textFaint : Theme.text
            font.family: win.muted ? Theme.font : Theme.mono
            font.pixelSize: Theme.fontSmall + 1
        }
    }
}
