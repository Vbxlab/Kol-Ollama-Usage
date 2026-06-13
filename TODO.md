# KOL Browser — Todo

## ✅ Fait (2026-05-11)

- [x] Ajouter .gitignore (.idea/, .kdev4/, *.kdev4)
- [x] Corriger l'auteur dans metadata.json (Vbxlab + Aï)
- [x] Ajouter le copyright Vbxlab dans LICENSE
- [x] Rendre bilingue FR/EN (Python `msg()` + QML `tr()`)
- [x] Ajouter config.qml (onglet General : intervalle refresh + langue)
- [x] Ajouter contents/config/main.xml (KConfig pour Plasma)
- [x] Corriger le bug regex session/weekly (les deux affichaient la même valeur pour les comptes Pro)
- [x] Ajouter gestion d'erreur granulaire dans le QML (python missing, script missing, invalid resp, network)
- [x] Corriger la description metadata.json
- [x] Améliorer install.sh (vérifications, messages, fallback upgrade)
- [x] Ajouter le fond du widget (DefaultBackground)
- [x] Corriger le bug des backslashes doublés dans extract_percent (regex `\s` cassé)
- [x] Corriger le DeprecationWarning locale.getdefaultlocale()
- [x] Configurer le panneau de config Plasma (ConfigModel + ConfigGeneral.qml)

## 🔲 À faire

- [ ] Tester le panneau de config (Configurer KOL Browser — s'ouvre mais comportement à valider)
- [ ] Ajouter un champ "Cookie" dans la config du widget (OLLAMA_COOKIE_HEADER) comme alternative pour les navigateurs chiffrés
- [ ] Documenter OLLAMA_COOKIE_HEADER dans le README
- [ ] Tester l'installation et le fonctionnement sur une session Plasma propre
- [ ] Ajouter un CHANGELOG.md
- [ ] Publier sur le KDE Store / Pling

## 🐛 Bugs connus

- [ ] Le rendu logiciel (`QT_XCB_FORCE_SOFTWARE_OPENGL=1`) peut causer des `No QSGTexture provided from updateSampledImage()` dans les logs — inoffensif mais bruyant
- [ ] Le thème Sweet affiche un warning legacy metadata.desktop — cosmétique, pas de notre ressort