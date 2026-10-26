import QtQuick

// [icon button] [slider] [percent]. The icon usually toggles mute.
// With `label` set, a caption line sits above the slider (per-app rows).
Item {
    id: root

    property string icon
    property string image
    property string label
    property real value: 0
    property bool muted: false
    property bool showPercent: true

    signal iconClicked()
    signal moved(real value)

    implicitWidth: Theme.panelWidth - 2 * Theme.panelPadding
    implicitHeight: label.length > 0 ? 50 : 32

    Text {
        id: caption
        visible: root.label.length > 0
        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.right: parent.right
        anchors.top: parent.top
        text: root.label
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        elide: Text.ElideRight
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 32

        IconButton {
            id: button
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            iconSize: 15
            tint: root.muted ? Theme.textFaint : Theme.text
            visible: root.image.length === 0
            onClicked: root.iconClicked()
        }

        // App rows show the app's own icon; clicking it still toggles mute.
        Item {
            anchors.fill: button
            visible: root.image.length > 0

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: root.image
                sourceSize.width: 36
                sourceSize.height: 36
                opacity: root.muted ? 0.4 : 1
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        ValueSlider {
            anchors.left: button.right
            anchors.leftMargin: 8
            anchors.right: percent.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            value: root.value
            fill: root.muted ? Theme.textFaint : Theme.accent
            onMoved: (v) => root.moved(v)
        }

        Text {
            id: percent
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: root.showPercent ? 36 : 0
            horizontalAlignment: Text.AlignRight
            text: root.muted ? "静音" : Math.round(root.value * 100) + "%"
            visible: root.showPercent
            color: root.muted ? Theme.textFaint : Theme.textDim
            font.family: root.muted ? Theme.font : Theme.mono
            font.pixelSize: Theme.fontSmall
        }
    }
}
