import QtQuick
import Quickshell

CenterPanel {
    id: panel

    shown: Launcher.open && Launcher.screen === shellScreen.name
    placeholder: "搜索应用"
    emptyText: "没有匹配的应用"
    hint: "↑↓ 选择 · Enter 打开 · Esc 关闭"
    model: shown ? Launcher.search(query) : []

    onAccepted: (index) => Launcher.run(model[index])
    onDismissed: Launcher.close()

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
            onClicked: Launcher.run(row.modelData)
        }

        Image {
            id: appIcon
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            source: Apps.iconFor(row.modelData, row.modelData.id)
            sourceSize.width: 56
            sourceSize.height: 56
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            mipmap: true
        }

        Column {
            anchors.left: appIcon.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: row.modelData.name
                color: row.current ? Theme.accent : Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontBody + 1
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                readonly property string sub: row.modelData.genericName || row.modelData.comment || ""
                visible: sub.length > 0
                text: sub
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                elide: Text.ElideRight
            }
        }
    }
}
