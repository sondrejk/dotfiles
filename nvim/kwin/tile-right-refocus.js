// Places the zathura preview window to the right of the terminal (which
// tile-left.js already moved to the left half), then refocuses the terminal.
var wins = workspace.windowList();
var zathura = null;
var terminal = null;
for (var i = 0; i < wins.length; i++) {
    var w = wins[i];
    if (w.resourceClass === "org.pwmt.zathura") zathura = w;
    if (w.resourceClass === "kitty") terminal = w;
}
if (zathura && terminal) {
    var t = terminal.frameGeometry;
    zathura.frameGeometry = {
        x: t.x + t.width,
        y: t.y,
        width: t.width,
        height: t.height,
    };
    workspace.activeWindow = terminal;
}
