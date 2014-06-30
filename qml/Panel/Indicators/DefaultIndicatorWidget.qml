/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorBase {
    id: indicatorWidget

    property int iconSize: units.gu(2)
    property alias leftLabel: itemLeftLabel.text
    property alias rightLabel: itemRightLabel.text
    property var icons: undefined

    width: itemRow.width
    enabled: false

    Row {
        id: itemRow
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: itemLeftLabel
            width: paintedWidth + units.gu(1)
            objectName: "leftLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
            horizontalAlignment: Text.AlignHCenter
        }

        Row {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            Repeater {
                model: indicatorWidget.icons

                Item {
                    width: itemImage.width + units.gu(1)
                    anchors { top: parent.top; bottom: parent.bottom }

                    /*
                      FIXME: should use Icon and the theme system
                      There is an Icon component in the SDK that the colorization is copied from.
                      We can't use it here unfortunately due to lack of support for image source
                      URIs and keeping aspect ratio.

                      Related bugs:
                       http://launchpad.net/bugs/1284235
                       http://launchpad.net/bugs/1284233
                     */

                    Image {
                        id: itemImage
                        objectName: "itemImage"
                        height: indicatorWidget.iconSize
                        sourceSize.height: height
                        anchors.centerIn: parent

                        onSourceChanged: console.debug(source)
                        visible: false

                        property string iconPath: "/usr/share/icons/suru/status/scalable/%1.svg"
                        property var icons: modelData.replace("image://theme/", "").split(",")
                        property int fallback: 0

                        onStatusChanged: if (status == Image.Error && fallback < icons.length - 1) fallback += 1;

                        // Needed to not introduce a binding loop on source
                        onFallbackChanged: updateSource()
                        Component.onCompleted: updateSource()
                        onIconsChanged: updateSource()

                        function updateSource() {
                            source = icons.length > 0 ? iconPath.arg(icons[fallback]) : "";
                        }
                    }

                    ShaderEffect {
                        id: colorizedImage

                        anchors.fill: itemImage

                        property Image source: itemImage.status == Image.Ready ? itemImage : null
                        property color keyColorOut: "#CCCCCC"
                        property color keyColorIn: "#808080"
                        property real threshold: 0.1

                        fragmentShader: "
                            varying highp vec2 qt_TexCoord0;
                            uniform sampler2D source;
                            uniform highp vec4 keyColorOut;
                            uniform highp vec4 keyColorIn;
                            uniform lowp float threshold;
                            uniform lowp float qt_Opacity;
                            void main() {
                                lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                gl_FragColor = mix(vec4(keyColorOut.rgb, 1.0) * sourceColor.a, sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, keyColorIn.rgb))) * qt_Opacity;
                            }"
                    }
                }
            }
        }

        Label {
            id: itemRightLabel
            width: paintedWidth + units.gu(1)
            objectName: "rightLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
            horizontalAlignment: Text.AlignHCenter
        }
    }

    onRootActionStateChanged: {
        if (rootActionState == undefined) {
            leftLabel = "";
            rightLabel = "";
            icons = undefined;
            enabled = false;
            return;
        }

        leftLabel = rootActionState.leftLabel ? rootActionState.leftLabel : "";
        rightLabel = rootActionState.rightLabel ? rootActionState.rightLabel : "";
        icons = rootActionState.icons;
        enabled = rootActionState.visible;
    }
}
