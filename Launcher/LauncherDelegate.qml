/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components 0.1
import QtGraphicalEffects 1.0
Item {
    id: root

    property string iconName

    property real angle: 0
    property bool highlighted: false
    property real offset: 0
    property alias brightness: transformEffect.brightness

    property real maxAngle: 0
    property bool inverted: false

    readonly property int effectiveHeight: Math.cos(angle * Math.PI / 180) * height
    readonly property real foldedHeight: Math.cos(maxAngle * Math.PI / 180) * height

    property int itemsBeforeThis: 0
    property int itemsAfterThis: 0

    property bool dragging:false

    signal clicked()
    signal longtap()
    signal released()

    Item {
        id: iconItem
        width: parent.width
        height: parent.height
        anchors.centerIn: parent

        UbuntuShape {
            color: Qt.rgba(0, 0, 1, 0.5)
            width: parent.width - units.gu(1)
            height: parent.height - units.gu(1)
            anchors.centerIn: parent
            radius: "medium"

            image: Image {
                id: iconImage
                source: "../graphics/applicationIcons/" + root.iconName + ".png"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: root.clicked()
                onCanceled: root.released()
                preventStealing: false

                onPressAndHold: {
                    root.state = "moving"
                }
                onReleased: {
                    root.state = "docked"
                }
            }

        }
        BorderImage {
            id: overlayHighlight
            anchors.centerIn: iconItem
            rotation: inverted ? 180 : 0
            source: root.highlighted || mouseArea.pressed ? "graphics/selected.sci" : "graphics/non-selected.sci"
            width: root.width + units.gu(0.5)
            height: width
        }
    }

    ShaderEffect {
        id: transformEffect
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        property real itemOpacity: root.opacity
        property real brightness: 0
        property real angle: root.angle
        rotation: root.inverted ? 180 : 0

        anchors.verticalCenterOffset: root.offset  + (height - root.effectiveHeight)/2 * (angle < 0 ? 1 : -1)

        property variant source: ShaderEffectSource {
            sourceItem: iconItem
            hideSource: true
        }

        transform: Rotation {
            axis { x: 1; y: 0; z: 0 }
            origin { x: iconItem.width / 2; y: iconItem.height / 2; z: 0 }
            angle: root.angle
        }

/*        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            varying highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            uniform lowp float angle;
            varying highp vec2 centerPoint;
            void main() {
                coord = qt_MultiTexCoord0;
                highp vec4 rotatedVertex = qt_Vertex * angle;
                gl_Position = qt_Matrix * rotatedVertex;
            }"
*/
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float brightness;
            uniform lowp float itemOpacity;
            void main(void)
            {
                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                sourceColor.rgb = mix(sourceColor.rgb, vec3(step(0.0, brightness)), abs(brightness));
                sourceColor *= itemOpacity;
                gl_FragColor = sourceColor;
            }"
    }

    QtObject {
        id: priv

        // The height of the area where icons start getting folded
        property int foldingAreaHeight: totalUnfoldedHeight * 0.75

        property real totalUnfoldedHeight: launcherFlickable.itemSize + launcherColumn.spacing
        property real totalEffectiveHeight: effectiveHeight + launcherColumn.spacing
        property real distanceFromTopEdge: -(launcherFlickable.contentY - itemsBeforeThis*totalUnfoldedHeight)
        property real distanceFromBottomEdge: launcherFlickable.height - (y+height) + launcherFlickable.contentY

        property real distanceFromEdge: Math.abs(distanceFromBottomEdge) < Math.abs(distanceFromTopEdge) ? distanceFromBottomEdge : distanceFromTopEdge
        property real orientationFlag: Math.abs(distanceFromBottomEdge) < Math.abs(distanceFromTopEdge) ? -1 : 1

        property real overlapWithFoldingArea: foldingAreaHeight - distanceFromEdge

    }

    states: [
        State {
            name: "docked"
            PropertyChanges {
                target: root

                offset: {
                    // First/last items are special
                    if (index == 0 || index == iconRepeater.count-1) {
                        // Just keep them bound to the edges in case they're outside of the visible area
                        if (priv.distanceFromEdge < 0) {
                            return (-priv.distanceFromEdge - (height - effectiveHeight)) * priv.orientationFlag;
                        }
                        return 0;
                    }

                    // Are we already completely outside the flickable? Stop the icon here.
                    if (priv.distanceFromEdge < -priv.totalUnfoldedHeight) {
                        return (-priv.distanceFromEdge - effectiveHeight) * priv.orientationFlag
                    }

                    // We're touching the edge, move slower than the actual flicking speed.
                    if (priv.distanceFromEdge < 0) {
                        return (Math.abs(priv.distanceFromEdge) * priv.totalEffectiveHeight / priv.totalUnfoldedHeight) * priv.orientationFlag
                    }

                    return 0;

                }

                angle: {
                    // First item is special
                    if (index == 0 || index == iconRepeater.count-1) {
                        if (priv.distanceFromEdge < 0) {
                            // distanceFromTopEdge : angle = totalUnfoldedHeight/2 : maxAngle
                            return Math.max(-maxAngle, priv.distanceFromEdge * maxAngle / (priv.foldingAreaHeight)) * priv.orientationFlag
                        }
                        return 0; // Don't fold first item as long as inside the view
                    }

                    // Are we in the already completely outside the flickable? Fold for the last 5 degrees
                    if (priv.distanceFromEdge < 0) {
                        // -distanceFromTopEdge : angle = totalUnfoldedHeight : 5
                        return Math.max(-maxAngle, (priv.distanceFromEdge * 5 / priv.foldingAreaHeight) - (maxAngle-5)) * priv.orientationFlag
                    }

                    // We are overlapping with the folding area, fold the icon to maxAngle - 5 degrees
                    if (priv.overlapWithFoldingArea > 0) {
                        // overlap: totalHeight = angle : (maxAngle - 5)
                        return -priv.overlapWithFoldingArea * (maxAngle -5) / priv.foldingAreaHeight * priv.orientationFlag;

                    }

                    return 0;
                }

                opacity: {
                    // First item is special
                    if (index == 0 || index == iconRepeater.count-1) {
                        if (priv.distanceFromEdge < 0) {
                            // Fade from 1 to 0 in the distance of 2 items height (which is when the next item reaches the edge)
                            return 1.0 - (-priv.distanceFromEdge / (priv.foldingAreaHeight * 3))
                        }
                        return 1; // Don't make first/last item transparent as long as inside the view
                    }

                    // Are we in the already completely outside the flickable? Fade to from 0.75 to 0 in twice 2 items height
                    if (priv.distanceFromEdge < 0) {
                        // -distanceFromEdge : 1-opacity = totalUnfoldedHeight : 0.75
                        return 0.75 - (-priv.distanceFromEdge * 0.75 / (priv.totalUnfoldedHeight*2))
                    }

                    // We are overlapping with the folding area, fade out to 0.75
                    if (priv.overlapWithFoldingArea > 0) {
                        // overlap : totalHeight = 1-opacity : 0.25
                        return 1 - (priv.overlapWithFoldingArea * 0.25 / priv.foldingAreaHeight)
                    }
                    return 1;
                }

                brightness: {
                    if (index == 0 || index == iconRepeater.count-1) {
                        if (priv.distanceFromEdge < 0) {
                            return -(-priv.distanceFromEdge / (priv.foldingAreaHeight * 3))
                        }
                        return 0;
                    }
                    if (priv.distanceFromEdge < 0) {
                        return -0.3 - (-priv.distanceFromEdge * 0.1 / (priv.totalUnfoldedHeight*2))
                    }

                    if (priv.overlapWithFoldingArea > 0) {
                        return - (priv.overlapWithFoldingArea * 0.3 / priv.foldingAreaHeight)
                    }
                    return 0;
                }
            }
        },

        State {
            name: "moving"
            PropertyChanges {
                target: launcherDelegate;
                offset: 0
                angle: 0
            }
            PropertyChanges {
                target: root
                highlighted: true
                dragging: true
            }
            PropertyChanges {
                target: mouseArea
                preventStealing: true
                drag.target: root
            }
        }

    ]

}
