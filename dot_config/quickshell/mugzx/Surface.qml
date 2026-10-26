import QtQuick
import QtQuick.Effects

// Rounded translucent card with a soft shadow; the bar and every panel use it.
// Windows that host one leave room around it for the shadow and mask input to it.
Item {
    id: root

    property real radius: Theme.panelRadius
    default property alias content: card.data

    RectangularShadow {
        anchors.fill: card
        radius: card.radius
        blur: 14
        spread: 0
        offset: Qt.vector2d(0, 3)
        color: Qt.rgba(0, 0, 0, 0.38)
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.radius
        color: Theme.bg
        border.width: 1
        border.color: Theme.border
    }
}
