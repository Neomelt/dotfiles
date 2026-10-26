import QtQuick

// Panel title with optional controls on the right.
Item {
    id: root

    property string title
    default property alias actions: actionRow.data

    implicitWidth: Theme.panelWidth - 2 * Theme.panelPadding
    implicitHeight: 28

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.fontTitle
        font.weight: Font.DemiBold
    }

    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
    }
}
