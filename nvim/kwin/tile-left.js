// Tiles the currently active window (the terminal, since this runs the
// instant the typst preview keymap fires) to the left half of its screen.
var w = workspace.activeWindow;
if (w) {
    var area = workspace.clientArea(KWin.MaximizeArea, w);
    w.frameGeometry = {
        x: area.x,
        y: area.y,
        width: Math.floor(area.width / 2),
        height: area.height,
    };
}
