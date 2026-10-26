import QtQuick

// Rounded hover target with a stroke icon. Used in the bar and in panels.
Item {
    id: root

    property string icon
    property real iconSize: 15
    property color tint: Theme.text
    property bool active: false          // its panel is open
    property bool badge: false           // small accent dot, e.g. unread notifications

    signal clicked(int button)
    signal scrolled(int steps)

    implicitWidth: iconSize + 12
    implicitHeight: iconSize + 12

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: root.active ? Theme.surfaceActive : area.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.anim } }
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.active ? Theme.accent : root.tint
    }

    Rectangle {
        visible: root.badge
        width: 5
        height: 5
        radius: 2.5
        color: Theme.accent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
    }

    MouseArea {
        id: area
        property real wheelAccum: 0
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (mouse) => root.clicked(mouse.button)
        // Touchpads send many small deltas; emit one step per wheel notch.
        onWheel: (wheel) => {
            wheelAccum += wheel.angleDelta.y;
            const steps = Math.trunc(wheelAccum / 120);
            if (steps !== 0) {
                wheelAccum -= steps * 120;
                root.scrolled(steps);
            }
        }
    }
}
