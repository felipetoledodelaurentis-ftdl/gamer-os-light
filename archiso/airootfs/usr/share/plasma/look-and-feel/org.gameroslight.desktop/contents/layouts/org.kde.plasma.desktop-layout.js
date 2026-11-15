// Gamer OS Light - layout inicial da area de trabalho (estilo Windows 11)
// Barra inferior com menu Iniciar e icones no centro; bandeja e relogio a direita.

var panel = new Panel;
panel.location = "bottom";
panel.height = 2 * Math.floor(gridUnit * 2.6 / 2);
panel.floating = false;
panel.alignment = "center";

panel.addWidget("org.kde.plasma.panelspacer");

var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["Shortcuts"];
kickoff.writeConfig("global", "Alt+F1");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "/usr/share/pixmaps/gameros-logo.svg");
kickoff.writeConfig("favoritesDisplay", 0);
kickoff.writeConfig("applicationsDisplay", 0);

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:firefox.desktop",
    "applications:steam.desktop",
    "applications:gamer-center.desktop",
    "applications:libreoffice-startcenter.desktop",
    "applications:org.kde.discover.desktop",
    "applications:org.kde.konsole.desktop"
].join(","));

panel.addWidget("org.kde.plasma.panelspacer");

panel.addWidget("org.kde.plasma.systemtray");

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", "BelowTime");

panel.addWidget("org.kde.plasma.showdesktop");

// Papel de parede em todas as areas de trabalho
var all = desktops();
for (var i = 0; i < all.length; ++i) {
    var d = all[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/wallpapers/GamerOSLight/");
}
