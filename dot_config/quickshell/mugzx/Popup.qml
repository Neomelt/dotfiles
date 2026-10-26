import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// One floating popup under the bar. All panels use this so they share width,
// position, look and close behaviour:
//   - drops down below the bar, aligned to the bar's left/right edge or centred
//   - click anywhere outside (HyprlandFocusGrab) or press Esc to close
//   - clicks on the bar still go through, so another button switches panels
PanelWindow {
    id: win

    required property string name
    required property var shellScreen
    required property var bar           // the bar window on this screen (exposes targetWidth)
    property string align: "right"      // "left" | "right" | "center"
    property int panelWidth: Theme.panelWidth
    default property alias content: column.data

    signal opened()

    readonly property bool shown: Panels.isOpen(name, shellScreen.name)
    readonly property int pad: 16       // room for the shadow
    property bool mapped: false         // stays true while the close animation runs

    onShownChanged: {
        if (shown) {
            mapped = true;
            unmapTimer.stop();
            flick.contentY = 0;
            opened();
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
    visible: shown || mapped
    color: "transparent"
    exclusiveZone: 0
    anchors.top: true
    anchors.left: true
    margins.top: Theme.barGap + Theme.barHeight + Theme.barGap - pad
    margins.left: {
        const sw = shellScreen.width;
        const bw = bar ? bar.targetWidth : panelWidth;
        const barLeft = (sw - bw) / 2;
        let left = align === "left" ? barLeft
                 : align === "right" ? barLeft + bw - panelWidth
                 : (sw - panelWidth) / 2;
        left = Math.max(Theme.barGap, Math.min(sw - panelWidth - Theme.barGap, left));
        return Math.max(0, Math.round(left - pad));
    }
    implicitWidth: panelWidth + 2 * pad
    implicitHeight: Math.min(Theme.panelMaxHeight, column.implicitHeight + 2 * Theme.panelPadding) + 2 * pad

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mugzx-panel"
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Only the card takes input; the shadow margin is click-through.
    mask: Region { item: card }

    HyprlandFocusGrab {
        active: win.shown
        windows: win.bar ? [win, win.bar] : [win]
        onCleared: if (win.shown) Panels.close()
    }

    Shortcut {
        sequence: "Escape"
        enabled: win.shown
        onActivated: Panels.close()
    }

    Surface {
        id: card
        x: win.pad
        y: win.pad
        width: win.panelWidth
        height: win.height - 2 * win.pad
        opacity: win.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }

        transform: Translate {
            y: win.shown ? 0 : -6
            Behavior on y { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        }

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: Theme.panelPadding
            contentWidth: width
            contentHeight: column.implicitHeight
            clip: contentHeight > height
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: column
                width: flick.width
                spacing: Theme.spacing
            }
        }
    }
}
