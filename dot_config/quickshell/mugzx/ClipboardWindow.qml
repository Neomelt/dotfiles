import QtQuick
import Quickshell

CenterPanel {
    id: panel

    shown: Clipboard.open && Clipboard.screen === shellScreen.name
    icon: "clipboard"
    placeholder: "搜索剪贴板"
    emptyText: !Clipboard.available ? "需要先安装 cliphist" : query.length > 0 ? "没有匹配的内容" : "还没有复制过东西"
    hint: "Enter 复制 · Shift+Del 删除 · Esc 关闭"
    rowHeight: 48
    model: shown ? Clipboard.filter(query) : []

    onAccepted: (index) => Clipboard.copy(model[index])
    onRemoveRequested: (index) => Clipboard.remove(model[index])
    onDismissed: Clipboard.close()

    TextButton {
        visible: Clipboard.items.length > 0
        text: "清空"
        danger: true
        onClicked: Clipboard.wipe()
    }

    delegate: Rectangle {
        id: row

        required property var modelData
        required property int index
        readonly property bool current: index === panel.currentIndex

        width: ListView.view.width - 16
        height: panel.rowHeight
        radius: Theme.rowRadius
        color: current ? Theme.surfaceActive : area.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: 80 } }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Clipboard.copy(row.modelData)
        }

        Rectangle {
            id: lead
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 36
            radius: 7
            color: Theme.surface
            clip: true

            Icon {
                anchors.centerIn: parent
                visible: !row.modelData.image || thumb.status !== Image.Ready
                name: row.modelData.image ? "image" : "clipboard"
                size: 15
                color: row.current ? Theme.accent : Theme.textDim
            }

            Image {
                id: thumb
                anchors.fill: parent
                visible: row.modelData.image
                source: row.modelData.image ? Clipboard.thumb(row.modelData) : ""
                sourceSize.width: 72
                sourceSize.height: 72
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }
        }

        Text {
            anchors.left: lead.right
            anchors.leftMargin: 12
            anchors.right: removeButton.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: row.modelData.image ? "图片 · " + row.modelData.text : row.modelData.text.trim()
            color: row.modelData.image ? Theme.textDim : row.current ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontBody
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        IconButton {
            id: removeButton
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            opacity: row.current || area.containsMouse ? 1 : 0.35
            icon: "x"
            iconSize: 12
            tint: Theme.textDim
            onClicked: Clipboard.remove(row.modelData)
        }
    }
}
