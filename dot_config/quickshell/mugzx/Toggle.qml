import QtQuick

// On/off switch. Emits toggled(); the owner flips the bound state.
Item {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 34
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Theme.track
        Behavior on color { ColorAnimation { duration: Theme.anim } }

        Rectangle {
            width: parent.height - 6
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Theme.accentFg : Theme.text
            Behavior on x { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
