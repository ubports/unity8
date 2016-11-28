/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {
    id: root
    width: topLayout.childrenRect.width + topLayout.anchors.leftMargin + topLayout.anchors.rightMargin
    height: topLayout.childrenRect.height + topLayout.anchors.topMargin + topLayout.anchors.bottomMargin
    color: theme.palette.normal.background
    radius: units.gu(.5)

    readonly property int maxTextSize: (root.parent.width / 4) - padding
    readonly property int padding: units.gu(4)

    Item { // dummy container to break binding loops *and* keep the margins in topLayout working
        GridLayout {
            id: topLayout
            anchors.fill: parent
            anchors.margins: padding
            columns: 2
            columnSpacing: padding

            Label {
                Layout.columnSpan: 2
                text: i18n.tr("Keyboard Shortcuts")
                fontSize: "large"
                font.weight: Font.Light
                lineHeight: 1.6
            }

            GridLayout {
                columns: 2
                columnSpacing: units.gu(4)
                Layout.alignment: Qt.AlignTop

                // Unity 8 section
                Label {
                    Layout.columnSpan: 2
                    text: i18n.tr("Unity 8")
                    font.weight: Font.Light
                    color: theme.palette.normal.baseText
                    lineHeight: 1.3
                }

                Label {
                    text: i18n.tr("PrtScr")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Takes a screenshot.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Alt + PrtScr")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Takes a screenshot of a window.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Super + Space")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Switches to next keyboard layout.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Super + Shift + Space")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Switches to previous keyboard layout.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }


                // Launcher section
                Item { Layout.columnSpan: 2; height: units.gu(2) }
                Label {
                    Layout.columnSpan: 2
                    text: i18n.tr("Launcher")
                    font.weight: Font.Light
                    color: theme.palette.normal.baseText
                    lineHeight: 1.3
                }

                Label {
                    text: i18n.tr("Super (Hold)")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Opens the launcher, displays shortcuts.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Alt + F1")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Opens launcher keyboard navigation mode.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Super + Tab")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Switches applications via the launcher.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Super + 0 to 9")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Same as clicking on a launcher icon.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }


                // Scopes section
                Item { Layout.columnSpan: 2; height: units.gu(2) }
                Label {
                    Layout.columnSpan: 2
                    text: i18n.tr("Scopes")
                    font.weight: Font.Light
                    color: theme.palette.normal.baseText
                    lineHeight: 1.3
                }

                Label {
                    text: i18n.tr("Super (Tap)")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Opens the Scopes home.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: padding
                Layout.alignment: Qt.AlignTop

                // Switching section
                Label {
                    Layout.columnSpan: 2
                    text: i18n.tr("Switching")
                    font.weight: Font.Light
                    color: theme.palette.normal.baseText
                    lineHeight: 1.3
                }

                Label {
                    text: i18n.tr("Alt + Tab")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Switches between applications.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Super + W")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Opens the desktop spread.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Cursor Left or Right")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Moves the focus.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }


                // Windows section
                Item { Layout.columnSpan: 2; height: units.gu(2) }
                Label {
                    Layout.columnSpan: 2
                    text: i18n.tr("Windows")
                    font.weight: Font.Light
                    color: theme.palette.normal.baseText
                    lineHeight: 1.3
                }

                Label {
                    text: i18n.tr("Ctrl + Super + D")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Minimizes all windows.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Ctrl + Super + Up")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Maximizes the current window.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Ctrl + Super + Down")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Minimizes or restores the current window.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Ctrl + Super + Left or Right")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Semi-maximizes the current window.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }

                Label {
                    text: i18n.tr("Alt + F4")
                    fontSize: "small"
                    font.weight: Font.Medium
                }
                Label {
                    text: i18n.tr("Closes the current window.")
                    fontSize: "small"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: maxTextSize
                }
            }

            Item { Layout.fillHeight: true; Layout.columnSpan: 2 } // spacer
        }
    }
}
