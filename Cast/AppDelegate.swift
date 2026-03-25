import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var castService: CastingService!
    private var settingsStore: SettingsStore!

    func applicationDidFinishLaunching(_ notification: Notification) {
        settingsStore = SettingsStore()
        castService = CastingService(settingsStore: settingsStore)

        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "Cast")
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "No device connected", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let castScreenItem = NSMenuItem(title: "Cast Screen", action: #selector(castScreen), keyEquivalent: "s")
        castScreenItem.keyEquivalentModifierMask = [.command, .shift]
        castScreenItem.target = self
        menu.addItem(castScreenItem)

        let castWindowItem = NSMenuItem(title: "Cast Window", action: #selector(castWindow), keyEquivalent: "w")
        castWindowItem.keyEquivalentModifierMask = [.command, .shift]
        castWindowItem.target = self
        menu.addItem(castWindowItem)

        let stopItem = NSMenuItem(title: "Stop Casting", action: #selector(stopCasting), keyEquivalent: "x")
        stopItem.keyEquivalentModifierMask = [.command, .shift]
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())

        let prefsItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Cast", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func setupPopover() {
        let contentView = ContentView(castingService: castService, settingsStore: settingsStore)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            statusItem.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            }
        }
    }

    @objc private func castScreen() {
        castService.startScreenCapture()
    }

    @objc private func castWindow() {
        castService.startWindowCapture()
    }

    @objc private func stopCasting() {
        castService.stopCasting()
    }

    @objc private func openPreferences() {
        // Preferences window - R2+
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
