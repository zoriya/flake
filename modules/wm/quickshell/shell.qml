import Quickshell
import QtQuick
import qs.widgets


ShellRoot {
	Bar {}

	Connections {
		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup();
		}

		target: Quickshell
	}
}
