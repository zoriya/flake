import Quickshell
import QtQuick

import qs.utils

Scope {
	Variants {
		model: Quickshell.screens

		delegate: Component {
			PanelWindow {
				required property var modelData

				screen: modelData
				anchors {
					top: true
					left: true
					right: true
				}
				color: Settings.colors.base

				implicitHeight: 30

				Text {
					anchors.centerIn: parent

					text: Qt.formatDateTime(clock.date, "hh:mm")
				}
			}
		}
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
}
