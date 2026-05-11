// KOL Browser — Configuration panel
// Authors: Vbxlab, Aï

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: config

    property alias cfg_RefreshInterval: refreshSpin.value

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Refresh interval (minutes):")
            font.weight: Font.DemiBold
        }

        QQC2.SpinBox {
            id: refreshSpin
            from: 1
            to: 60
            stepSize: 1
            value: 5
        }

        QQC2.Label {
            text: i18n("How often the widget checks your Ollama quotas.")
            font: Kirigami.Theme.smallFont
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}