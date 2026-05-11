// KOL Browser — General configuration panel
// Authors: Vbxlab, Aï

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: generalConfig

    property alias cfg_RefreshInterval: refreshSpin.value
    property alias cfg_Language: langCombo.currentIndex

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: "Refresh interval (minutes) / Intervalle de rafraîchissement (minutes) :"
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
            text: "Language / Langue :"
            font.weight: Font.DemiBold
        }

        QQC2.ComboBox {
            id: langCombo
            model: ["Auto", "English", "Français"]
            // 0=Auto, 1=English, 2=French
        }

        QQC2.Label {
            text: "'Auto' follows your system locale. / « Auto » suit la langue du système."
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}