import QtQuick
import Quickshell.Hyprland

// Workspace dots for one monitor: active = accent pill, occupied = brighter dot.
// Shows 1..5, or more when a higher workspace (up to 10) exists.
Row {
    id: root

    required property var shellScreen

    readonly property var monitor: Hyprland.monitorFor(shellScreen)
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 1
    readonly property var all: Hyprland.workspaces.values

    readonly property var occupied: {
        const o = {};
        for (let i = 0; i < all.length; i++)
            if (all[i].toplevels.values.length > 0)
                o[all[i].id] = true;
        return o;
    }

    readonly property int count: {
        let m = 5;
        for (let i = 0; i < all.length; i++)
            if (all[i].id > m && all[i].id <= 10)
                m = all[i].id;
        return activeId > m && activeId <= 10 ? activeId : m;
    }

    spacing: 0

    Repeater {
        model: root.count

        Item {
            id: slot
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: wsId === root.activeId
            readonly property bool used: !!root.occupied[wsId]
            width: active ? 26 : 14
            height: 24
            Behavior on width { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.centerIn: parent
                width: slot.active ? 16 : 6
                height: 6
                radius: 3
                color: slot.active ? Theme.accent
                     : area.containsMouse ? Theme.text
                     : slot.used ? Theme.textDim : Theme.textFaint
                Behavior on width { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: Theme.anim } }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + slot.wsId + " })")
            }
        }
    }
}
