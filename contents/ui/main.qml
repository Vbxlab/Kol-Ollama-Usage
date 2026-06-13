// KOL Browser — Plasma 6 widget for Ollama cloud token usage
// Authors: Vbxlab, Aï

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property string settingsUrl: "https://ollama.com/settings"
    readonly property string helperPath: Qt.resolvedUrl("../code/fetch_usage.py").toString().replace("file://", "")

    property real sessionValue: 0
    property real weeklyValue: 0
    property bool authenticated: false
    property bool busy: false
    property string statusMessage: ""
    property string lastCommand: ""

    // Config
    property int cfgRefreshInterval: Plasmoid.configuration.refreshInterval || 5
    property string cfgCookieHeader: Plasmoid.configuration.cookieHeader || ""

    implicitWidth: Kirigami.Units.gridUnit * 14
    implicitHeight: Kirigami.Units.gridUnit * 8
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground

    function barColor(value) {
        if (value >= 95) return Kirigami.Theme.negativeTextColor
        if (value >= 80) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.highlightColor
    }

    function barColorWeekly(value) {
        if (value >= 95) return Kirigami.Theme.negativeTextColor
        if (value >= 80) return Kirigami.Theme.neutralTextColor
        return Qt.rgba(
            Kirigami.Theme.positiveTextColor.r,
            Kirigami.Theme.positiveTextColor.g,
            Kirigami.Theme.positiveTextColor.b,
            0.85
        )
    }

    function refreshUsage() {
        if (busy) return;

        // Validate helper path
        if (!helperPath || helperPath === "") {
            authenticated = false;
            statusMessage = i18n("Helper script not found.");
            return;
        }

        const cookie = root.cfgCookieHeader.trim();
        let command = "python3 \"" + helperPath + "\"";
        if (cookie) {
            command = "OLLAMA_COOKIE_HEADER=\"" + cookie + "\" " + command;
        }
        lastCommand = command;
        busy = true;
        statusMessage = "";
        executableSource.connectSource(command);
    }

    function openSettings() {
        Qt.openUrlExternally(root.settingsUrl);
    }

    function applyResult(result) {
        if (!result) {
            authenticated = false;
            statusMessage = i18n("Could not read Ollama quotas.");
            return;
        }

        if (result.status === "ok" && result.session && result.weekly) {
            authenticated = true;
            sessionValue = result.session.value;
            weeklyValue = result.weekly.value;
            statusMessage = "";
            return;
        }

        authenticated = false;
        if (result.status === "login") {
            statusMessage = i18n("Log in to Ollama in your browser, then refresh.");
        } else {
            statusMessage = result.message || i18n("Could not read Ollama quotas.");
        }
    }

    Component.onCompleted: refreshUsage()

    Timer {
        id: refreshTimer
        interval: cfgRefreshInterval * 60000
        repeat: true
        running: true
        onTriggered: root.refreshUsage()
    }

    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"

        onNewData: function(sourceName, data) {
            if (sourceName !== root.lastCommand) {
                return;
            }

            executableSource.disconnectSource(sourceName);
            root.busy = false;

            const stdout = (data["stdout"] || "").trim();
            const stderr = (data["stderr"] || "").trim();
            const exitCode = data["exit code"];

            // Python3 not found
            if (exitCode !== 0 && stderr && (stderr.includes("not found") || stderr.includes("command not found") || stderr.includes("No such file"))) {
                root.authenticated = false;
                root.statusMessage = i18n("Python 3 not found. Please install python3.");
                return;
            }

            if (!stdout) {
                root.authenticated = false;
                root.statusMessage = stderr || i18n("Could not read Ollama quotas.");
                return;
            }

            try {
                root.applyResult(JSON.parse(stdout));
            } catch (error) {
                root.authenticated = false;
                root.statusMessage = i18n("Invalid response from Ollama helper.");
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: i18n("Ollama Usage")
                font.weight: Font.Bold
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.16)

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: root.busy ? "..." : "↻"
                    color: Kirigami.Theme.textColor
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !root.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.refreshUsage()
                }

                PlasmaComponents3.ToolTip {
                    text: root.busy ? "" : i18n("Refresh")
                }
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                radius: height / 2
                color: Qt.rgba(
                    Kirigami.Theme.highlightColor.r,
                    Kirigami.Theme.highlightColor.g,
                    Kirigami.Theme.highlightColor.b,
                    0.9
                )

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: "O"
                    color: Kirigami.Theme.highlightedTextColor
                    font.weight: Font.Black
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openSettings()
                }

                PlasmaComponents3.ToolTip {
                    text: "ollama.com/settings"
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                visible: root.authenticated
                spacing: Kirigami.Units.largeSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: i18n("Session")
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.textColor
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: Qt.rgba(1, 1, 1, 0.16)
                        }

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, root.sessionValue)) / 100
                            height: parent.height
                            radius: height / 2
                            color: root.barColor(root.sessionValue)
                        }

                        PlasmaComponents3.Label {
                            anchors.centerIn: parent
                            text: Number(root.sessionValue).toFixed(1) + "%"
                            color: Kirigami.Theme.highlightedTextColor
                            font.weight: Font.DemiBold
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: i18n("Weekly")
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.textColor
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: Qt.rgba(1, 1, 1, 0.16)
                        }

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, root.weeklyValue)) / 100
                            height: parent.height
                            radius: height / 2
                            color: root.barColorWeekly(root.weeklyValue)
                        }

                        PlasmaComponents3.Label {
                            anchors.centerIn: parent
                            text: Number(root.weeklyValue).toFixed(1) + "%"
                            color: Kirigami.Theme.textColor
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width
                visible: !root.authenticated
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.statusMessage || i18n("Log in to Ollama in your browser, then refresh.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.textColor
                }

                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Click the Ollama logo to open the connection.")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.disabledTextColor
                }
            }
        }
    }
}