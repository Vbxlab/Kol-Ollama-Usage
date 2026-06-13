// KOL Browser — General configuration panel
// Authors: Vbxlab, Aï

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: generalConfig

    property alias cfg_refreshInterval: refreshSpin.value
    property alias cfg_cookieHeader: cookieField.text

    ColumnLayout {
        anchors.fill: parent
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

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        QQC2.Label {
            text: i18n("Ollama cookie header (optional, overrides browser cookies):")
            font.weight: Font.DemiBold
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: cookieField
            Layout.fillWidth: true
            placeholderText: i18n("Paste your cookie header here…")
        }

        QQC2.Label {
            text: i18n("Only needed if browser cookies are unavailable (e.g. encrypted Chromium cookies). Get it from your browser's DevTools → Network → request headers → Cookie.")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}