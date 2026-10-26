import QtQuick
import Quickshell
import Quickshell.Networking

// Wi-Fi: on/off, scan list, connect (with password prompt inline), disconnect.
Popup {
    id: root

    name: "wifi"
    align: "right"

    property var expanded: null       // network showing the password field
    property var failed: null         // network whose last attempt failed
    property string failText: ""

    onOpened: {
        expanded = null;
        failed = null;
    }

    function activate(n) {
        failed = null;
        if (n.connected) {
            expanded = expanded === n ? null : n;
            return;
        }
        if (Net.isEnterprise(n) && !n.known) {
            Panels.close();
            System.networkSettings();
            return;
        }
        if (n.known || !Net.needsPassword(n)) {
            expanded = null;
            n.connect();
            return;
        }
        expanded = expanded === n ? null : n;
    }

    PanelHeader {
        width: parent.width
        title: "Wi-Fi"

        IconButton {
            icon: "sliders"
            iconSize: 14
            tint: Theme.textDim
            onClicked: { Panels.close(); System.networkSettings(); }
        }

        Toggle {
            anchors.verticalCenter: parent.verticalCenter
            checked: Net.wifiEnabled
            onToggled: Net.setWifiEnabled(!Net.wifiEnabled)
        }
    }

    ListRow {
        width: parent.width
        visible: Net.wiredConnected
        icon: "ethernet"
        title: "有线网络"
        subtitle: "已连接"
        interactive: false
    }

    Text {
        width: parent.width
        visible: !Net.wifiEnabled
        text: "Wi-Fi 已关闭"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
        topPadding: 6
        bottomPadding: 6
    }

    Text {
        width: parent.width
        visible: Net.wifiEnabled && Net.sorted.length === 0
        text: "正在搜索网络…"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
        topPadding: 6
        bottomPadding: 6
    }

    Column {
        width: parent.width
        visible: Net.wifiEnabled
        spacing: 2

        Repeater {
            model: ScriptModel { values: Net.wifiEnabled ? Net.sorted : [] }

            Column {
                id: entry
                required property var modelData
                readonly property var net: modelData
                readonly property bool busy: net.stateChanging || net.state === ConnectionState.Connecting
                readonly property bool isExpanded: root.expanded === net
                width: parent.width
                spacing: 4

                Connections {
                    target: entry.net
                    function onConnectionFailed(reason) {
                        root.failed = entry.net;
                        root.failText = Net.failText(reason);
                        // Wrong or missing password: ask again.
                        if (Net.needsPassword(entry.net) && !Net.isEnterprise(entry.net))
                            root.expanded = entry.net;
                    }
                    function onConnectedChanged() {
                        if (entry.net.connected && root.expanded === entry.net)
                            root.expanded = null;
                    }
                }

                ListRow {
                    width: parent.width
                    icon: "wifi"
                    title: entry.net.name
                    subtitle: entry.busy ? "正在连接…"
                            : entry.net.connected ? "已连接"
                            : root.failed === entry.net ? root.failText
                            : entry.net.known ? "已保存"
                            : Net.needsPassword(entry.net) ? "" : "开放网络"
                    selected: entry.net.connected
                    onClicked: root.activate(entry.net)

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Net.needsPassword(entry.net) && !entry.net.connected
                        name: "lock"
                        size: 11
                        color: Theme.textFaint
                    }

                    SignalBars {
                        anchors.verticalCenter: parent.verticalCenter
                        strength: entry.net.signalStrength
                    }
                }

                // Connected network: disconnect / forget.
                Row {
                    visible: entry.isExpanded && entry.net.connected
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    spacing: 6

                    TextButton {
                        text: "忘记"
                        onClicked: { root.expanded = null; entry.net.forget(); }
                    }

                    TextButton {
                        text: "断开"
                        onClicked: { root.expanded = null; entry.net.disconnect(); }
                    }
                }

                // New secured network: password prompt.
                Item {
                    visible: entry.isExpanded && !entry.net.connected
                    width: parent.width
                    height: 30

                    onVisibleChanged: {
                        if (visible) {
                            password.text = "";
                            password.forceActiveFocus();
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: connectButton.left
                        anchors.rightMargin: 6
                        height: parent.height
                        radius: 8
                        color: Theme.surface
                        border.width: 1
                        border.color: password.activeFocus ? Theme.accent : Theme.border

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.text
                            selectionColor: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: Theme.fontBody
                            clip: true
                            onAccepted: connectButton.clicked()
                        }

                        Text {
                            anchors.fill: password
                            verticalAlignment: Text.AlignVCenter
                            visible: password.text.length === 0
                            text: "输入密码"
                            color: Theme.textFaint
                            font.family: Theme.font
                            font.pixelSize: Theme.fontBody
                        }
                    }

                    TextButton {
                        id: connectButton
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "连接"
                        primary: true
                        enabled: password.text.length >= 8
                        onClicked: {
                            if (password.text.length < 8)
                                return;
                            root.failed = null;
                            entry.net.connectWithPsk(password.text);
                            root.expanded = null;
                        }
                    }
                }
            }
        }
    }
}
