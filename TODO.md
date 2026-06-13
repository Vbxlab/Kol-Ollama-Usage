# KOL Browser — Todo

## ✅ Fait (2026-05-11)

- [x] Ajouter .gitignore (.idea/, .kdev4/, *.kdev4)
- [x] Corriger l'auteur dans metadata.json (Vbxlab + Aï)
- [x] Ajouter le copyright Vbxlab dans LICENSE
- [x] Corriger le bug regex session/weekly (les deux affichaient la même valeur pour les comptes Pro)
- [x] Ajouter gestion d'erreur granulaire dans le QML (python missing, script missing, invalid resp, network)
- [x] Corriger la description metadata.json
- [x] Améliorer install.sh (vérifications, messages, fallback upgrade)
- [x] Ajouter le fond du widget (DefaultBackground)
- [x] Corriger le bug des backslashes doublés dans extract_percent (regex `\s` cassé)
- [x] Corriger le DeprecationWarning locale.getdefaultlocale()

## ✅ Fait (2026-06-13)

- [x] Configurer le panneau de config (Structure Plasma 6 corrigée : config.qml → contents/config/, ConfigGeneral.qml → contents/ui/config/)
- [x] Titre "Ollama Usage" en haut du widget
- [x] Barres de progression colorées par seuil (< 80% normal, ≥ 80% orange, ≥ 95% rouge)
- [x] Migrer vers i18n() natif KDE (suppression du système tr() maison et msg() Python)
- [x] Nettoyer metadata.json ID : com.vincent.kol.external2 → org.vbxlab.kol
- [x] CHANGELOG.md créé
- [x] README.md enrichi (description, installation, config, dépendances, cookie override)

## 🔲 À faire

- [x] Ajouter un champ "Cookie" dans la config du widget (OLLAMA_COOKIE_HEADER) comme alternative pour les navigateurs chiffrés
- [x] Screenshot du widget pour le README
- [x] Tester l'installation et le fonctionnement sur une session Plasma propre
- [x] Publier sur le KDE Store / Pling

## 🐛 Bugs connus

- [ ] Le rendu logiciel (`QT_XCB_FORCE_SOFTWARE_OPENGL=1`) peut causer des `No QSGTexture provided from updateSampledImage()` dans les logs — inoffensif mais bruyant
- [ ] Le thème Sweet affiche un warning legacy metadata.desktop — cosmétique, pas de notre ressort