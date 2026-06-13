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
    property int cfgLanguage: Plasmoid.configuration.language || 0  // 0=Auto, 1=EN, 2=FR

    implicitWidth: Kirigami.Units.gridUnit * 14
    implicitHeight: Kirigami.Units.gridUnit * 8
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground

    function tr(source) {
        // Simple bilingual lookup: English | French
        const translations = {
            "session":               "Session",
            "weekly":                "Weekly",
            "click_o":               "Click the Ollama logo to open the connection.",
            "click_o_fr":            "Cliquez sur le logo Ollama pour ouvrir la connexion.",
            "login_required":        "Log in to Ollama in your browser, then refresh.",
            "login_required_fr":     "Connectez-vous à Ollama dans le navigateur, puis actualisez.",
            "no_cookie":             "No Ollama cookie found. Log in with your default browser, then refresh.",
            "no_cookie_fr":          "Aucun cookie Ollama trouvé. Connectez-vous dans le navigateur par défaut puis actualisez.",
            "read_fail":             "Could not read Ollama quotas.",
            "read_fail_fr":          "Impossible de lire les quotas Ollama.",
            "invalid_resp":          "Invalid response from Ollama helper.",
            "invalid_resp_fr":       "Réponse invalide du helper Ollama.",
            "python_missing":        "Python 3 not found. Please install python3.",
            "python_missing_fr":     "Python 3 introuvable. Veuillez installer python3.",
            "script_missing":        "Helper script not found.",
            "script_missing_fr":     "Script helper introuvable.",
            "timeout":               "Request to Ollama timed out.",
            "timeout_fr":            "La requête vers Ollama a expiré.",
            "network_error":         "Network error contacting Ollama.",
            "network_error_fr":      "Erreur réseau en contactant Ollama.",
        };

        // Language: 0=Auto (system locale), 1=English, 2=French
        let isFrench;
        if (cfgLanguage === 2) {
            isFrench = true;
        } else if (cfgLanguage === 1) {
            isFrench = false;
        } else {
            isFrench = Qt.locale().name.startsWith("fr");
        }

        if (isFrench) {
            const frKey = source + "_fr";
            if (translations[frKey] !== undefined) return translations[frKey];
        }
        return translations[source] || source;
    }

    function refreshUsage() {
        if (busy) return;

        // Validate helper path
        if (!helperPath || helperPath === "") {
            authenticated = false;
            statusMessage = tr("script_missing");
            return;
        }

        const command = "python3 \"" + helperPath + "\"";
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
            statusMessage = tr("read_fail");
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
            statusMessage = tr("login_required");
        } else {
            statusMessage = result.message || tr("read_fail");
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
                root.statusMessage = tr("python_missing");
                return;
            }

            if (!stdout) {
                root.authenticated = false;
                root.statusMessage = stderr || tr("read_fail");
                return;
            }

            try {
                root.applyResult(JSON.parse(stdout));
            } catch (error) {
                root.authenticated = false;
                root.statusMessage = tr("invalid_resp");
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
                text: "Ollama Usage"
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
                    text: root.busy ? "" : root.tr("login_required").split(",")[0]
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
                        text: root.tr("session")
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
                        text: root.tr("weekly")
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
                    text: root.statusMessage || root.tr("login_required")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.textColor
                }

                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.tr("click_o")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.disabledTextColor
                }
            }
        }
    }
}