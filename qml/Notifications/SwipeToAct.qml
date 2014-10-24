/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import QtGraphicalEffects 1.0

Item {
	id: swipeToAct

    width: parent.width
    height: childrenRect.height

    signal leftTriggered()
    signal rightTriggered()

    property string leftIconName
    property string rightIconName
    readonly property double sliderHeight: 6
    readonly property double gap: units.gu(1)
    readonly property double halfWay: mouseArea.drag.maximumX / 2

    Rectangle {
    	id: gradient
    	width: parent.width * 5
    	height: units.gu(sliderHeight)
    	visible: false
		LinearGradient {
			anchors.fill: parent
			start: Qt.point(parent.x, parent.y)
			end: Qt.point(parent.width, parent.y)
			gradient: Gradient {
				GradientStop { position: 0.0; color: UbuntuColors.red }
				GradientStop { position: 0.2; color: UbuntuColors.red }
				GradientStop { position: 0.4; color: "#dddddd" }
				GradientStop { position: 0.6; color: "#dddddd" }
				GradientStop { position: 0.8; color: UbuntuColors.green }
				GradientStop { position: 1.0; color: UbuntuColors.green }
			}
		}
    }

    ShaderEffectSource {
    	id: effectSourceGradient
    	sourceItem: gradient
    	width: gradient.width
    	height: gradient.height
    	sourceRect: Qt.rect(0.4 * gradient.width * (slider.x / halfWay), 0, mask.width, mask.height)
    	visible: false
    	hideSource: true
    }

    UbuntuShape {
    	id: mask
    	color: "black"
    	width: parent.width
    	height: units.gu(sliderHeight)
    	borderSource: "none"
    	visible: false
    }

    ShaderEffectSource {
    	id: effectSourceMask
    	sourceItem: mask
    	width: mask.width
    	height: mask.height
    	visible: false
    	hideSource: true
    }

    ShaderEffect {
    	width: parent.width
    	height: units.gu(sliderHeight)
		property variant mask: effectSourceMask
        property variant gradient: effectSourceGradient
        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }"
        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D mask;
            uniform sampler2D gradient;
            void main() {
                lowp vec4 texMask = texture2D(mask, coord);
                lowp vec4 texGradient = texture2D(gradient, coord);
                gl_FragColor = texGradient.rgba * texMask.a ;
            }"

	    Row {
	    	id: row
	    	anchors.fill: parent
	    	spacing: gap
	    	anchors.margins: gap

	    	UbuntuShape {
	    		id: leftShape
	    		states: [
	    		    State {
	    		    	name: "normal"
	    		    	PropertyChanges {
	    		    		target: leftShape
	    		    		color: UbuntuColors.red
	    		    	}
	    		    	PropertyChanges {
	    		    		target: innerLeftShape
	    		    		color: UbuntuColors.red
	    		    		visible: false
	    		    	}
	    		    },
	    		    State {
	    		    	name: "selected"
	    		    	PropertyChanges {
	    		    		target: leftShape
	    		    		color: "white"
	    		    	}
	    		    	PropertyChanges {
	    		    		target: innerLeftShape
	    		    		color: UbuntuColors.red
	    		    		visible: true
	    		    	}
	    		    }
	    		]
	    		state: "normal"
	    		height: units.gu(4)
	    		width: units.gu(7)
	    		borderSource: "none"
	    		opacity: slider.x <= halfWay ? 1.0 : 1.0 - ((slider.x - halfWay) / halfWay)
	    		UbuntuShape {
	    			id: innerLeftShape
	    			anchors.centerIn: parent
	    			borderSource: "none"
	    			width: parent.width - units.gu(.5)
	    			height: parent.height - units.gu(.5)
	    		}
	    		Icon {
	    			anchors.centerIn: parent
	    			width: units.gu(2)
					height: units.gu(2)
					name: leftIconName
					color: "white"
	    		}
	    	}

	    	Rectangle {
	    		id: leftSpacer
	    		width: (row.width - (leftShape.width + slider.width + rightShape.width + 4 * row.spacing)) / 2
	    		height: units.gu(4)
	    		opacity: 0
	    	}

	    	UbuntuShape {
	    		id: slider
	    		objectName: "slider"

				Behavior on x {
					UbuntuNumberAnimation {
						duration: UbuntuAnimation.FastDuration
						easing.type: Easing.OutBounce
					}
				}

			    Behavior on opacity {
			        UbuntuNumberAnimation {
			        	duration: UbuntuAnimation.FastDuration
			        }
			    }

			    onOpacityChanged: {
			    	if (opacity === 0) {
			    		if (rightShape.state === "selected") {
			    			rightTriggered()
			    		}
			    		if (leftShape.state === "selected") {
			    			leftTriggered()
			    		}
			    	}
			    }

	    		z: 1
	    		color: "white"
	    		height: units.gu(4)
	    		width: units.gu(7)
	    		borderSource: "none"
	    		Row {
	    			anchors.fill: parent
	    			spacing: 2 * gap
	    			anchors.leftMargin: units.gu(.5)
	    			anchors.rightMargin: units.gu(.5)
	    			Icon {
		    			anchors.verticalCenter: parent.verticalCenter
	    				name: "back"
	    				width: units.gu(2)
	    				height: units.gu(2)
	    			}
	    			Icon {
		    			anchors.verticalCenter: parent.verticalCenter
	    				name: "next"
	    				width: units.gu(2)
	    				height: units.gu(2)
	    			}
	    		}
	    	}

	    	Rectangle {
	    		id: rightSpacer
	    		width: leftSpacer.width
	    		height: units.gu(4)
	    		opacity: 0
	    	}

	    	UbuntuShape {
	    		id: rightShape
	    		states: [
	    		    State {
	    		    	name: "normal"
	    		    	PropertyChanges {
	    		    		target: rightShape
	    		    		color: UbuntuColors.green
	    		    	}
	    		    	PropertyChanges {
	    		    		target: innerRightShape
	    		    		color: UbuntuColors.green
	    		    		visible: false
	    		    	}
	    		    },
	    		    State {
	    		    	name: "selected"
	    		    	PropertyChanges {
	    		    		target: rightShape
	    		    		color: "white"
	    		    	}
	    		    	PropertyChanges {
	    		    		target: innerRightShape
	    		    		color: UbuntuColors.green
	    		    		visible: true
	    		    	}
	    		    }
	    		]
	    		state: "normal"
	    		height: units.gu(4)
	    		width: units.gu(7)
	    		borderSource: "none"
	    		opacity: slider.x >= halfWay ? 1.0 : slider.x / halfWay
	    		UbuntuShape {
	    			id: innerRightShape
	    			anchors.centerIn: parent
	    			borderSource: "none"
	    			width: parent.width - units.gu(.5)
	    			height: parent.height - units.gu(.5)
	    		}
	    		Icon {
	    			anchors.centerIn: parent
	    			width: units.gu(2)
					height: units.gu(2)
					name: rightIconName
					color: "white"
	    		}
	    	}
	    }

	    MouseArea {
	    	id: mouseArea
            objectName: "swipeMouseArea"

	    	anchors.fill: row
	    	drag.target: slider
			drag.axis: Drag.XAxis
			drag.minimumX: 0
			drag.maximumX: row.width - slider.width

			onReleased: {
				if (slider.x !== drag.minimumX || slider.x !== drag.maximumX) {
					slider.x = halfWay
				}
				if (slider.x === drag.minimumX) {
					slider.x = drag.minimumX
					slider.opacity = 0
					enabled = false
					leftShape.state = "selected"
				}
				if (slider.x === drag.maximumX) {
					slider.x = drag.maximumX
					slider.opacity = 0
					enabled = false
					rightShape.state = "selected"
				}
			}
	    }
    }
}

