import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "DialogFit.js" as DialogFit

// Headless service: when a window opens, wait for it to settle, and if it is a floating window
// smaller than a usable minimum, grow it and center it on its monitor. See DialogFit.js.
Item {
  id: root

  property var pendingAddresses: []
  property var openedClients: []

  function onWindowOpened(data) {
    // openwindow payload: ADDRESS,WORKSPACE,CLASS,TITLE (address has no 0x prefix)
    var address = "0x" + String(data).split(",")[0]
    if (root.pendingAddresses.indexOf(address) < 0) root.pendingAddresses.push(address)
    settleTimer.restart()
  }

  function parse(text) {
    try { return JSON.parse(text) } catch (e) { return null }
  }

  function handleClients(text) {
    var all = parse(text)
    if (!all) { root.pendingAddresses = []; return }
    root.openedClients = all.filter(function(c) { return root.pendingAddresses.indexOf(c.address) >= 0 })
    root.pendingAddresses = []
    if (root.openedClients.length > 0) monitorsProcess.running = true
  }

  function handleMonitors(text) {
    var monitors = parse(text)
    if (!monitors) return
    for (var i = 0; i < root.openedClients.length; i++) {
      var client = root.openedClients[i]
      var monitor = monitors.filter(function(m) { return m.id === client.monitor })[0]
      var plan = DialogFit.plan(client, monitor)
      if (!plan) continue
      var cmds = DialogFit.luaCommands(client.address, plan)
      console.log("dialog-fit: " + client.class + " " + client.size[0] + "x" + client.size[1] + " -> " + plan.w + "x" + plan.h)
      dispatchQueue.push(cmds)
    }
    root.openedClients = []
    runNextDispatch()
  }

  property var dispatchQueue: []

  function runNextDispatch() {
    if (dispatchProcess.running || dispatchQueue.length === 0) return
    var cmds = dispatchQueue.shift()
    dispatchProcess.command = ["bash", "-c", "hyprctl dispatch \"$1\" >/dev/null; hyprctl dispatch \"$2\" >/dev/null", "_", cmds[0], cmds[1]]
    dispatchProcess.running = true
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "openwindow") root.onWindowOpened(event.data)
    }
  }

  Timer {
    id: settleTimer
    interval: 300
    repeat: false
    onTriggered: clientsProcess.running = true
  }

  Process {
    id: clientsProcess
    command: ["hyprctl", "-j", "clients"]
    stdout: StdioCollector { onStreamFinished: root.handleClients(text) }
  }

  Process {
    id: monitorsProcess
    command: ["hyprctl", "-j", "monitors"]
    stdout: StdioCollector { onStreamFinished: root.handleMonitors(text) }
  }

  Process {
    id: dispatchProcess
    onExited: root.runNextDispatch()
  }
}
