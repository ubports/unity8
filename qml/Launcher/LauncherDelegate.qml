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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property int itemIndex: 0
    property string iconName
    property int count: 0
    property bool countVisible: false
    property int progress: -1
    property bool itemRunning: false
    property bool itemFocused: false
    property real maxAngle: 0
    property bool inverted: false
    property bool alerting: false
    property bool highlighted: false
    property bool shortcutHintShown: false

    readonly property int effectiveHeight: Math.cos(angle * Math.PI / 180) * itemHeight
    readonly property real foldedHeight: Math.cos(maxAngle * Math.PI / 180) * itemHeight
    readonly property alias wiggling: wiggleAnim.running

    property int itemWidth
    property int itemHeight
    // The angle used for rotating
    property real angle: 0
    // This is the offset that keeps the items inside the panel
    property real offset: 0
    property real itemOpacity: 1
    property real brightness: 0
    property double maxWiggleAngle: 5.0

    QtObject {
        id: priv

        readonly property int wiggleDuration: UbuntuAnimation.SnapDuration
        property real wiggleAngle: 0
    }

    SequentialAnimation {
        id: wiggleAnim

        running: alerting
        loops: 1
        alwaysRunToEnd: true

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: 0
            to: maxWiggleAngle
            duration: priv.wiggleDuration
            easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: maxWiggleAngle
            to: -maxWiggleAngle
            duration: priv.wiggleDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: -maxWiggleAngle
            to: maxWiggleAngle
            duration: priv.wiggleDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: maxWiggleAngle
            to: -maxWiggleAngle
            duration: priv.wiggleDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: -maxWiggleAngle
            to: maxWiggleAngle
            duration: priv.wiggleDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: priv
            property: "wiggleAngle"
            from: maxWiggleAngle
            to: 0
            duration: priv.wiggleDuration
            easing.type: Easing.OutQuad
        }

        UbuntuNumberAnimation {
            target: root
            property: "alerting"
            to: 0
        }
    }

    Item {
        id: iconItem
        width: root.width
        height: parent.itemHeight + units.gu(1)
        anchors.centerIn: parent

        Image {
            objectName: "focusRing"
            anchors.centerIn: iconShape
            height: width * 15 / 16
            width: iconShape.width + units.gu(1)
            source: "graphics/launcher-app-focus-ring.svg"
            sourceSize.width: width
            sourceSize.height: height
            visible: root.highlighted
        }

        ProportionalShape {
            id: iconShape
            anchors.centerIn: parent
            width: root.itemWidth
            aspect: UbuntuShape.DropShadow
            source: Image {
                id: iconImage
                sourceSize.width: iconShape.width
                sourceSize.height: iconShape.height
                source: root.iconName
                cache: false // see lpbug#1543290 why no cache
            }
        }

        UbuntuShape {
            id: countEmblem
            objectName: "countEmblem"
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: (iconItem.width - root.itemWidth) / 2 - units.dp(2)
                margins: units.dp(5)
            }
            width: Math.min(root.itemWidth, Math.max(units.gu(2), countLabel.implicitWidth + units.gu(1)))
            height: units.gu(2)
            backgroundColor: UbuntuColors.orange
            visible: root.countVisible
            aspect: UbuntuShape.Flat

            Label {
                id: countLabel
                objectName: "countLabel"
                text: root.count
                anchors.centerIn: parent
                // FIXME: verticalCenter seems to be off wee bit and QML doesn't have a centerLine
                // property for Text: https://bugreports.qt-project.org/browse/QTBUG-40479
                anchors.verticalCenterOffset: -units.dp(.5)
                width: root.itemWidth - units.gu(1)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: "white"
                fontSize: "x-small"
            }
        }

        UbuntuShape {
            id: progressOverlay
            objectName: "progressOverlay"

            anchors.centerIn: parent
            width: root.itemWidth * .8
            height: units.gu(1)
            visible: root.progress > -1
            backgroundColor: UbuntuColors.darkGrey
            borderSource: "none"

            Item {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.min(100, root.progress) / 100 * parent.width
                clip: true

                UbuntuShape {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    backgroundColor: "white"
                    borderSource: "none"
                    width: progressOverlay.width
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            spacing: units.gu(.5)
            Repeater {
                model: 1 // TODO: This should be "Math.min(3, app.surfaceCount)" once we have multiple surfaces
                Rectangle {
                    objectName: "runningHighlight" + index
                    width: units.gu(0.25)
                    height: units.gu(.5)
                    color: "white"
                    visible: root.itemRunning
                }
            }
        }

        Rectangle {
            objectName: "focusedHighlight"
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            width: units.gu(0.25)
            height: units.gu(.5)
            color: "white"
            visible: root.itemFocused
        }

        Rectangle {
            objectName: "shortcutHint"
            anchors.centerIn: parent
            width: units.gu(3)
            height: width
            color: "#E0292929"
            visible: root.shortcutHintShown
            Label {
                anchors.centerIn: parent
                text: (itemIndex + 1) % 10
                color: "white"
                font.weight: Font.DemiBold
            }
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
            // The rotation about the icon's center/z-axis for the wiggle
            // needs to happen here too, because there's no other way to
            // align the wiggle with the icon-folding otherwise
            Rotation {
                axis { x: 0; y: 0; z: 1 }
                origin { x: iconItem.width / 2; y: iconItem.height / 2; z: 0 }
                angle: priv.wiggleAngle
            },
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
