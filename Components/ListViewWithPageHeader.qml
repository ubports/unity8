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
import "Math.js" as MathLocal

Item {
    id: root
    property Item pageHeader: null
    property Component sectionDelegate: null
    property string sectionProperty: ""
    property alias model: listView.model
    property alias delegate: listView.delegate
    property ListView view: listView
    property alias moving: flicker.moving
    property alias atYEnd: flicker.atYEnd
    property bool clipListView: true

    readonly property real __headerHeight: (pageHeader) ? pageHeader.implicitHeight : 0
    property real __headerVisibleHeight: __headerHeight
    readonly property real __overshootHeight: (flicker.contentY < 0) ? -flicker.contentY : 0


    // TODO move to AnimationController
    ParallelAnimation {
        id: headerAnimation
        property real targetContentY
        NumberAnimation {
            target: root
            property: "__headerVisibleHeight"
            to: root.__headerHeight
            duration: 200
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: listView
            property: "contentY"
            to: headerAnimation.targetContentY
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    function positionAtBeginning() {
        __headerVisibleHeight = __headerHeight
        flicker.contentY = 0
    }

    function showHeader() {
        headerAnimation.targetContentY = listView.contentY + (__headerHeight - __headerVisibleHeight)
        headerAnimation.start()
    }

    function flick(xVelocity, yVelocity) {
        flicker.flick(xVelocity, yVelocity);
    }

    onPageHeaderChanged: {
        pageHeader.parent = pageHeaderContainer;
        pageHeader.anchors.fill = pageHeaderContainer;
    }

    Item {
        id: pageHeaderClipper
        parent: flicker // parent to Flickable so mouse click events passed through to the header component
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: __headerVisibleHeight + __overshootHeight

        Item {
            id: pageHeaderContainer
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: __headerHeight + __overshootHeight
        }
    }

    ListView {
        id: listView
        parent: flicker // parent to Flickable so mouse click events passed through to List delegates
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: __headerVisibleHeight
        }
        height: root.height

        // FIXME scrolling workaround, see below
        cacheBuffer: height*10

        section.property: sectionProperty
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
        section.delegate: sectionDelegate

        interactive: false
        clip: root.clipListView

        property int __sectionDelegateHeight: __getHeight(section.delegate)
        function __getHeight(component) {
            // want height (minus allowed overlap) of the section delegate as is needed for clipping
            if (component === null) return 0;
            var object = component.createObject(); //FIXME: throws 'section' not defined error
            var value = object.height - object.bottomBorderAllowedOverlap;
            object.destroy();
            return value;
        }

        property real previousOriginY: 0
        onOriginYChanged: {
            var deltaOriginY = originY - previousOriginY;
            previousOriginY = originY;
            /* When originY changes, it causes the top of the flicker and the top of the list to fall
               out of sync - and thus the contentY positioning will be broken. To correct for this we
               manually change the flickable's contentY here */
            flicker.contentY -= deltaOriginY;
        }

        /* For case when list content greater than container height and list scrolled down so header
           hidden. If content shrinks to be smaller than the container height, we want the header to
           re-appear */
        property real __previousContentHeight: 0
        onContentHeightChanged: {
            var deltaContentHeight = contentHeight - __previousContentHeight;
            __previousContentHeight = contentHeight;
            if (contentHeight < height && deltaContentHeight < 0 && __headerVisibleHeight < height - contentHeight) {
                __headerVisibleHeight = Math.min(height - contentHeight, __headerHeight);
            }
        }
    }

    Flickable {
        id: flicker
        anchors.fill: parent
        contentHeight: listView.contentHeight + __headerHeight
        maximumFlickVelocity: height * 10
        flickDeceleration: height * 2
        onContentYChanged: {
            var deltaContentY = contentY - __previousContentY;
            __previousContentY = contentY;

            // first decide if movement will prompt the page header to change height
            if ((deltaContentY < 0 && __headerVisibleHeight >= 0) ||
                    (deltaContentY > 0 && __headerVisibleHeight <= __headerHeight)) {

                // calculate header height - but prevent bounce from changing it
                if (contentY > 0 && contentY < contentHeight - height) {
                    __headerVisibleHeight = MathLocal.clamp(__headerVisibleHeight - deltaContentY, 0, __headerHeight);
                }
            }

            // now we move list position, taking into account page header height

            // BUG: With section headers enabled, the values of originY and contentY appear not
            // correct at the exact point originY changes. originY changes when the ListView
            // deletes/creates hidden delegates which are above the visible delegates.
            // As a result of this bug, you experience jittering scrolling when rapidly moving
            // around in large lists. See https://bugreports.qt-project.org/browse/QTBUG-27997
            // A workaround is to use a large enough cacheBuffer to prevent deletions/creations
            // so effectively originY is always zero.
            var newContentY = flicker.contentY + listView.originY - __headerHeight + __headerVisibleHeight
            if (newContentY < listView.contentHeight) {
                listView.contentY = newContentY;
            }
        }

        property real __previousContentY: 0
    }
}
