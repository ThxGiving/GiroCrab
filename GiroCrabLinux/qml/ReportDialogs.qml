pragma Singleton
import QtQuick

// ReportDialogs.swift (#384): the dialogs Hilfe › Problem melden draws over the main window.
// Every sheet (Sheet.qml) and every popover (a Popup) registers here while it is open, like
// `.capturableSheet` / `.capturablePopover` on the Mac: BugReportWindow draws it at its place
// over the window, redacted like the window (`Sensitive {}` reads the same AppModel bits in
// every window). Text fields, text editors, pop-up menus (ComboBox) and web pages in a
// dialog are covered by the capture itself; everything else in it needs `Sensitive {}` like
// in the main window. A popup that is not registered – an alert or confirmation dialog
// (ConfirmDialog, `reportCapturable: false`), a menu, a native file dialog – is never drawn:
// the picture then shows what lies under it, and the report says so.
QtObject {
    /// The open, capturable popups (Sheet, popovers).
    property var popups: []

    function track(popup) {
        if (popup && popups.indexOf(popup) < 0) popups = popups.concat([popup])
    }
    function untrack(popup) {
        if (popups.indexOf(popup) >= 0) popups = popups.filter(p => p !== popup)
    }
    /// The item a popup draws into (Popup.popupItem is not exposed to QML).
    function itemOf(popup) {
        const c = popup.background || popup.contentItem
        return c ? c.parent : null
    }
    /// The registered popup drawn by `item` (a child of a window's overlay), or null.
    function popupFor(item) {
        for (const p of popups) if (itemOf(p) === item) return p
        return null
    }
}
