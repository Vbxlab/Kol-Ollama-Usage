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
    readonly property int refreshIntervalMs: 300000
    readonly property string helperPath: Qt.resolvedUrl("../code/fetch_usage.py").toString().replace("file://", "")

    property real sessionValue: 0
    property real weeklyValue: 0
    property bool authenticated: false
    property bool busy: false
    property string statusMessage: "Connectez-vous a Ollama dans le navigateur, puis actualisez."
    property string lastCommand: ""

    implicitWidth: Kirigami.Units.gridUnit * 14
    implicitHeight: Kirigami.Units.gridUnit * 8
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function refreshUsage() {
        const command = "python3 \"" + helperPath + "\"";
        lastCommand = command;
        busy = true;
        executableSource.connectSource(command);
    }

    function openSettings() {
        Qt.openUrlExternally(root.settingsUrl);
    }

    function applyResult(result) {
        if (!result) {
            authenticated = false;
            statusMessage = "Impossible de lire les quotas Ollama.";
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
        statusMessage = result.message || "Connectez-vous a Ollama dans le navigateur, puis actualisez.";
    }

    Component.onCompleted: refreshUsage()

    Timer {
        id: refreshTimer
        interval: root.refreshIntervalMs
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
            if (!stdout) {
                root.authenticated = false;
                root.statusMessage = (data["stderr"] || "Impossible de recuperer les donnees Ollama.").trim();
                return;
            }

            try {
                root.applyResult(JSON.parse(stdout));
            } catch (error) {
                root.authenticated = false;
                root.statusMessage = "Reponse invalide du helper Ollama.";
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true

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
                        text: "session"
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
                            color: Kirigami.Theme.highlightColor
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
                        text: "weekly"
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
                            color: Qt.rgba(
                                Kirigami.Theme.positiveTextColor.r,
                                Kirigami.Theme.positiveTextColor.g,
                                Kirigami.Theme.positiveTextColor.b,
                                0.85
                            )
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
                    text: root.statusMessage
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.textColor
                }

                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Cliquez sur le logo Ollama pour ouvrir la connexion."
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.disabledTextColor
                }
            }
        }
    }
}
