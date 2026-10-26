import QtQuick

// Two-column quick setting tile in the control panel.
Rectangle {
    id: root

    property string icon
    property string title
    property bool checked: false

    signal clicked()

    implicitHeight: 44
    radius: Theme.rowRadius
    color: checked ? Theme.surfaceActive : area.containsMouse ? Theme.surfaceHover : Theme.surface
    Behavior on color { ColorAnimation { duration: Theme.anim } }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 16
            color: root.checked ? Theme.accent : Theme.text
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            color: root.checked ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontBody
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
