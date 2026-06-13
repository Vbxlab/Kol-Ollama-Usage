// KOL Browser — Configuration model
// Authors: Vbxlab, Aï

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system"
        source: "config/ConfigGeneral.qml"
    }
}