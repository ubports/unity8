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

Item {
    id: root

    property string iconName
    property int count: -1
    property int progress: -1
    property bool highlighted: false
    property bool itemFocused: false
    property real maxAngle: 0
    property bool inverted: false

    readonly property int effectiveHeight: Math.cos(angle * Math.PI / 180) * itemHeight
    readonly property real foldedHeight: Math.cos(maxAngle * Math.PI / 180) * itemHeight

    property int itemWidth
    property int itemHeight
    // The angle used for rotating
    property real angle: 0
    // This is the offset that keeps the items inside the panel
    property real offset: 0
    property real itemOpacity: 1
    property real brightness: 0

    Item {
        id: iconItem
        width: parent.itemWidth + units.gu(1)
        height: parent.itemHeight + units.gu(1)
        anchors.centerIn: parent

        UbuntuShape {
            id: iconShape
            anchors.fill: parent
            anchors.margins: units.gu(1)
            radius: "medium"
            borderSource: "none"

            image: Image {
                id: iconImage
                sourceSize.width: iconShape.width
                sourceSize.height: iconShape.height
                fillMode: Image.PreserveAspectCrop
                source: root.iconName
            }
        }

        BorderImage {
            id: overlayHighlight
            anchors.centerIn: iconItem
            rotation: inverted ? 180 : 0
            source: root.highlighted ? "graphics/selected.sci" : "graphics/non-selected.sci"
            width: root.itemWidth + units.gu(0.5)
            height: root.itemHeight + units.gu(0.5)
        }

        BorderImage {
            objectName: "countEmblem"
            anchors {
                right: parent.right
                top: parent.top
                margins: units.dp(3)
            }
            width: Math.min(root.itemWidth, Math.max(units.gu(3), countLabel.implicitWidth + units.gu(2.5)))
            height: units.gu(3)
            source: "graphics/notification.sci"
            visible: root.count > 0

            Label {
                id: countLabel
                text: root.count
                anchors.centerIn: parent
                width: root.itemWidth - units.gu(1)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: "white"
                fontSize: "small"
                font.bold: true
            }
        }

        BorderImage {
            id: progressOverlay
            objectName: "progressOverlay"
            anchors {
                left: iconItem.left
                right: iconItem.right
                bottom: iconItem.bottom
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
                bottomMargin: units.gu(1)
            }
            height: units.gu(1.5)
            visible: root.progress > -1
            source: "graphics/progressbar-trough.sci"

            // For fill calculation we need to remove the 2 units of border defined in .sci file
            property int adjustedWidth: width - units.gu(2)

            Item {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.min(100, root.progress) / 100 * parent.adjustedWidth + units.gu(1)
                clip: true

                BorderImage {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: progressOverlay.width
                    source: "graphics/progressbar-fill.sci"
                }
            }
        }
        Image {
            objectName: "focusedHighlight"
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            visible: root.itemFocused
            source: "graphics/focused_app_arrow.png"
        }
    }

    ShaderEffect {
        id: transformEffect
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.offset
        width: iconItem.width
        height: iconItem.height
        property real itemOpacity: root.itemOpacity
        property real brightness: Math.max(-1, root.brightness)
        property real angle: root.angle
        rotation: root.inverted ? 180 : 0

        property variant source: ShaderEffectSource {
            id: shaderEffectSource
            sourceItem: iconItem
            hideSource: true
        }

        transform: [
            // Rotating 3 times at top/bottom because that increases the perspective.
            // This is a hack, but as QML does not support real 3D coordinates
            // getting a higher perspective can only be done by a hack. This is the most
            // readable/understandable one I could come up with.
            Rotation {
                axis { x: 1; y: 0; z: 0 }
                origin { x: iconItem.width / 2; y: angle > 0 ? 0 : iconItem.height; z: 0 }
                angle: root.angle * 0.7
            },
            Rotation {
                axis { x: 1; y: 0; z: 0 }
                origin { x: iconItem.width / 2; y: angle > 0 ? 0 : iconItem.height; z: 0 }
                angle: root.angle * 0.7
            },
            Rotation {
                axis { x: 1; y: 0; z: 0 }
                origin { x: iconItem.width / 2; y: angle > 0 ? 0 : iconItem.height; z: 0 }
                angle: root.angle * 0.7
            },
            // Because rotating it 3 times moves it more to the front/back, i.e. it gets
            // bigger/smaller and we need a scale to compensate that again.
            Scale {
                xScale: 1 - (Math.abs(angle) / 500)
                yScale: 1 - (Math.abs(angle) / 500)
                origin { x: iconItem.width / 2; y: iconItem.height / 2}
            }
        ]

        // Using a fragment shader instead of QML's opacity and BrightnessContrast
        // to be able to do both in one step which gives quite some better performance
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
}
