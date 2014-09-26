import QtQuick 2.0
import Ubuntu.Components 1.1

Item {
	id: swipeToAct

    property alias leftText: leftLabel.text
    property alias rightText: rightLabel.text

    signal leftTriggered()
    signal rightTriggered()

    readonly property double redH: 0.991
    readonly property double redS: 0.892
    readonly property double redL: 0.563
    readonly property double greenH: 0.386
    readonly property double greenS: 1.0
    readonly property double greenL: 0.316
    readonly property double sliderHeight: 4
    readonly property color lightGrey: "#eaeaea"
    readonly property color black: "#000000"
    readonly property color textColor: "#ffffff"

    Row {
    	id: row

    	width: swipeToAct.width
    	clip: true

	    UbuntuShape {
	    	id: leftShape

	    	property double scale: width / ((row.width - slider.width) / 2)
	    	color: Qt.hsla(redH, redS * (scale < 1.0 ? scale : 1.0), redL, 1.0)
	    	opacity: scale < 1.0 ? scale : 1.0
	    	width: slider.x
        	height: units.gu(sliderHeight)
        	Label {
        		id: leftLabel

        		anchors.centerIn: parent
        		color: textColor
        		fontSize: "medium"
        	}
	    }

	    UbuntuShape {
	    	id: slider

			Behavior on x {
				id: xBehavior

				UbuntuNumberAnimation {
					duration: UbuntuAnimation.FastDuration
					easing.type: Easing.OutBounce
				}
			}

			onXChanged: {
				if (x === 0.0) {
					rightTriggered()
				}
				if (x === row.width - slider.width) {
					leftTriggered()
				}
			}

	    	color: lightGrey
	    	x: (row.width - slider.width) / 2
	    	width: units.gu(7)
        	height: units.gu(sliderHeight)
        	z: 1
	    }

	    UbuntuShape {
	    	id: rightShape

	    	property double scale: width / ((row.width - slider.width) / 2)
	    	color: Qt.hsla(greenH, greenS * (scale < 1.0 ? scale : 1.0), greenL, 1.0)
	    	opacity: scale < 1.0 ? scale : 1.0
	    	x: slider.x + slider.width
	    	width: row.width - (leftShape.width + slider.width)
        	height: units.gu(sliderHeight)
        	Label {
				id: rightLabel

        		anchors.centerIn: parent
        		color: textColor
        		fontSize: "medium"
        	}
	    }
    }

    MouseArea {
    	id: mouseArea

    	anchors.fill: row
    	drag.target: slider
		drag.axis: Drag.XAxis
		drag.minimumX: 0
		drag.maximumX: row.width - slider.width

		onReleased: {
			if (slider.x !== 0 || slider.x !== row.width - slider.width) {
				slider.x = (row.width - slider.width) / 2
			}
			if (slider.x < units.gu(.5)) {
				slider.x = 0
			}
			if (slider.x > row.width - slider.width - units.gu(.5)) {
				slider.x = row.width - slider.width
			}
		}
    }
}

