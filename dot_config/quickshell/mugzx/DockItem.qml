import QtQuick
import Quickshell
import Quickshell.Hyprland

// One app in the dock: icon, a dot per open window (up to 3), name tooltip.
Item {
    id: root

    required property string appKey
    required property var host

    readonly property var entry: DesktopEntries.byId(appKey)
    readonly property var wins: host.windowsFor(appKey)
    readonly property bool focused: wins.includes(Hyprland.activeToplevel)
    readonly property bool menuOpen: host.menuKey === appKey
    readonly property string label: entry ? entry.name : appKey

    // Pulses the icon between a click and the app's first window.
    property bool launching: false
    onWinsChanged: if (wins.length > 0) launching = false

    Timer {
        id: launchTimeout
        interval: 8000
        onTriggered: root.launching = false
    }

    function start() {
        if (!entry)
            return;
        if (wins.length === 0) {
            launching = true;
            launchTimeout.restart();
        }
        host.launch(appKey);
    }

    width: host.slot
    height: host.cardHeight

    Rectangle {
        anchors.centerIn: icon
        width: root.host.slot - 6
        height: width
        radius: 12
        color: root.menuOpen ? Theme.surfaceActive : area.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.anim } }
    }

    Image {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height - height) / 2 - 3
        width: root.host.iconSize
        height: width
        source: Apps.iconFor(root.entry, root.appKey)
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        scale: area.pressed ? 0.9 : area.containsMouse ? 1.1 : 1
        Behavior on scale { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }

        SequentialAnimation on opacity {
            running: root.launching
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 450; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1; duration: 450; easing.type: Easing.InOutQuad }
            onRunningChanged: if (!running) icon.opacity = 1
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        spacing: 3

        Repeater {
            model: Math.min(root.wins.length, 3)

            Rectangle {
                required property int index
                width: root.focused && index === 0 ? 10 : 4
                height: 4
                radius: 2
                color: root.focused ? Theme.accent : Theme.textDim
                Behavior on width { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: Theme.anim } }
            }
        }
    }

    // Drawn in the click-through space above the card; kept inside the dock window.
    Rectangle {
        id: tip
        visible: opacity > 0
        opacity: area.containsMouse && root.host.menuKey === "" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }
        x: {
            const off = root.host.pad + root.host.sidePad + root.x;
            const want = (root.width - width) / 2;
            return Math.max(2 - off, Math.min(root.host.width - off - width - 2, want));
        }
        y: -height - 8
        width: tipText.implicitWidth + 16
        height: 24
        radius: 7
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        Text {
            id: tipText
            anchors.centerIn: parent
            text: root.wins.length > 1 ? root.label + " · " + root.wins.length + " 个窗口" : root.label
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (root.menuOpen)
                    root.host.closeMenu();
                else
                    root.host.openMenu(root.appKey, root);
                return;
            }
            root.host.closeMenu();
            if (mouse.button === Qt.MiddleButton || root.wins.length === 0)
                root.start();
            else
                root.host.activate(root.appKey);
        }
    }
}
