pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root
	property QtObject colors

	colors: QtObject {
		readonly property color base: "#313244"
	}
}
