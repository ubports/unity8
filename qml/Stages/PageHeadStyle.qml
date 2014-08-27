/*
 * Copyright 2014 Canonical Ltd.
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
 */
import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Styles 1.1 as Style

// FIXME: copied with large modifications from Ubuntu UI Toolkit's Ambiance's theme
Style.PageHeadStyle {
    id: headerStyle

    contentHeight: units.gu(7)
    separatorSource: "graphics/PageHeaderBaseDividerLight.sci"
    separatorBottomSource: "graphics/PageHeaderBaseDividerBottom.png"
    fontWeight: Font.Light
    fontSize: "x-large"
    textColor: styledItem.config.foregroundColor
    textLeftMargin: units.gu(2)

    implicitHeight: headerStyle.contentHeight

    Label {
        anchors {
            left: parent.left
            leftMargin: headerStyle.textLeftMargin
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
        text: styledItem.title
        font.weight: headerStyle.fontWeight
        fontSize: headerStyle.fontSize
        color: headerStyle.textColor
        elide: Text.ElideRight
    }

    BorderImage {
        id: separator
        anchors {
            top: parent.bottom
            topMargin: separatorBottom.height
            left: parent.left
            right: parent.right
        }
        source: headerStyle.separatorSource
        height: styledItem.config.sections.model !== undefined ? units.gu(3) : units.gu(2)
        asynchronous: true
        cache: true
    }

    Image {
        id: separatorBottom
        anchors {
            top: separator.bottom
            left: parent.left
            right: parent.right
        }
        source: headerStyle.separatorBottomSource
        asynchronous: true
        cache: true
    }
}
