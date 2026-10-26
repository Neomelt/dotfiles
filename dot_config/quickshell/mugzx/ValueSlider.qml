import QtQuick

// Horizontal 0..1 slider: press or drag to set, scroll to nudge by `step`.
// It does not own the value; bind `value` and write back in onMoved.
Item {
    id: root

    property real value: 0
    property real step: 0.05
    property color fill: Theme.accent

    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 20

    readonly property real shown: area.pressed ? area.dragValue : Math.max(0, Math.min(1, value))

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.track

        Rectangle {
            width: Math.max(parent.height, track.width * root.shown)
            height: parent.height
            radius: 2
            color: root.enabled ? root.fill : Theme.textFaint
        }
    }

    Rectangle {
        width: 12
        height: 12
        radius: 6
        x: (root.width - width) * root.shown
        anchors.verticalCenter: parent.verticalCenter
        color: root.enabled ? Theme.text : Theme.textFaint
        scale: area.pressed || area.containsMouse ? 1.15 : 1
        Behavior on scale { NumberAnimation { duration: Theme.anim } }
    }

    MouseArea {
        id: area
        property real dragValue: 0
        property real wheelAccum: 0
        anchors.fill: parent
        anchors.topMargin: -6
        anchors.bottomMargin: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function valueAt(x) {
            return Math.max(0, Math.min(1, x / width));
        }

        onPressed: (mouse) => {
            dragValue = valueAt(mouse.x);
            root.moved(dragValue);
        }
        onPositionChanged: (mouse) => {
            if (!pressed)
                return;
            dragValue = valueAt(mouse.x);
            root.moved(dragValue);
        }
        onWheel: (wheel) => {
            wheelAccum += wheel.angleDelta.y;
            const steps = Math.trunc(wheelAccum / 120);
            if (steps === 0)
                return;
            wheelAccum -= steps * 120;
            const v = Math.max(0, Math.min(1, root.value + steps * root.step));
            root.moved(Math.round(v * 100) / 100);
        }
    }
}
