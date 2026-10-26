import QtQuick

// Small pill button with a text label.
Rectangle {
    id: root

    property string text
    property bool primary: false
    property bool danger: false

    signal clicked()

    implicitWidth: label.implicitWidth + 18
    implicitHeight: 24
    radius: 7
    opacity: enabled ? 1 : 0.4
    color: primary ? (area.containsMouse ? Qt.lighter(Theme.accent, 1.08) : Theme.accent)
         : danger ? Qt.rgba(0.92, 0.48, 0.48, area.containsMouse ? 0.28 : 0.16)
         : area.containsMouse ? Theme.surfaceHover : Theme.surface
    Behavior on color { ColorAnimation { duration: Theme.anim } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.primary ? Theme.accentFg : root.danger ? Theme.danger : Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
