import QtQuick

// Clickable row: leading icon, title, optional subtitle and trailing items.
Rectangle {
    id: root

    property string icon
    property string image            // themed app icon path, used instead of `icon`
    property string title
    property string subtitle
    property bool selected: false
    property bool danger: false      // armed destructive action (power panel)
    property bool dim: false
    property bool interactive: true
    default property alias trailing: trailingRow.data

    signal clicked()

    implicitWidth: Theme.panelWidth - 2 * Theme.panelPadding
    implicitHeight: subtitle.length > 0 ? 42 : Theme.rowHeight
    radius: Theme.rowRadius
    color: danger ? Qt.rgba(0.92, 0.48, 0.48, 0.18)
         : selected ? Theme.surfaceActive
         : interactive && area.containsMouse ? Theme.surfaceHover : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.anim } }

    // Declared first so trailing buttons sit above it and get their own clicks.
    MouseArea {
        id: area
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Item {
        id: lead
        width: 18
        height: 18
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            anchors.centerIn: parent
            visible: root.image.length === 0
            name: root.icon
            size: 16
            color: root.danger ? Theme.danger : root.selected ? Theme.accent : root.dim ? Theme.textFaint : Theme.textDim
        }

        Image {
            anchors.fill: parent
            visible: root.image.length > 0
            source: root.image
            sourceSize.width: 36
            sourceSize.height: 36
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    Column {
        anchors.left: lead.right
        anchors.leftMargin: 10
        anchors.right: trailingRow.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.title
            color: root.danger ? Theme.danger : root.dim ? Theme.textDim : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontBody
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Theme.textFaint
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            elide: Text.ElideRight
        }
    }

    Row {
        id: trailingRow
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
    }
}
