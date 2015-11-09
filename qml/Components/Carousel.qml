/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import "carousel.js" as CarouselJS

/*! The Carousel component presents the items of a model in a carousel view. It's similar to a
    cover flow. But it stops at it's boundaries (therefore no PathView is used).
  */
Item {
    id: carousel

    clip: true // Don't leak horizontally to other dashes

    /// The component to be used as delegate. This component has to be derived from BaseCarouselDelegate
    property Component itemComponent
    /// Model for the Carousel, which has to be a model usable by a ListView
    property alias model: listView.model
    /// A minimal width of a tile can be set here. Per default a best fit will be calculated
    property alias minimumTileWidth: listView.minimumTileWidth
    /// Sets the number of tiles that are visible
    property alias pathItemCount: listView.pathItemCount
    /// Aspect ratio of the tiles width/height
    property alias tileAspectRatio: listView.tileAspectRatio
    /// Used to cache some delegates for performance reasons. See the ListView documentation for details
    property alias cacheBuffer: listView.cacheBuffer
    property alias displayMarginBeginning: listView.displayMarginBeginning
    property alias displayMarginEnd: listView.displayMarginEnd
    /// Width of the "draw buffer" in pixel. The drawBuffer is an additional area at start/end where
    /// items drawn, even if it is not in the visible area.
    /// cacheBuffer controls only the to retain delegates outside the visible area (and is used on top of the drawBuffer)
    /// see https://bugreports.qt-project.org/browse/QTBUG-29173
    property int drawBuffer: width / pathItemCount // an "ok" value - but values used from the listView cause loops
    /// The selected item can be shown in a different size controlled by selectedItemScaleFactor
    property real selectedItemScaleFactor: 1.1
    /// The extra margin at the bottom
    property real extraBottomMargin: 0
    /// The index of the item that should be highlighted
    property alias highlightIndex: listView.highlightIndex
    /// exposes the delegate of the currentItem
    readonly property alias currentItem: listView.currentItem
    /// exposes the distance to the next row (only one row in carousel, so it's the topMargins)
    readonly property alias verticalSpacing: listView.verticalMargin
    /// the width of the internal list
    readonly property alias innerWidth: listView.width

    implicitHeight: listView.tileHeight * selectedItemScaleFactor
    opacity: listView.highlightIndex === -1 ? 1 : 0.6

    /* Basic idea behind the carousel effect is to move the items of the delegates (compacting /stuffing them).
       One drawback is, that more delegates have to be drawn than usually. As some items are moved from the
       invisible to the visible area. Setting the cacheBuffer does not fix this.
       See https://bugreports.qt-project.org/browse/QTBUG-29173
       Therefore the ListView has negative left and right anchors margins, and in addition a header
       and footer item to compensate that.

       The scaling of the items is controlled by the variable continuousIndex, described below. */
    ListView {
        id: listView
        objectName: "listView"

        property int highlightIndex: -1
        property real minimumTileWidth: 0
        property real newContentX: disabledNewContentX
        property real pathItemCount: referenceWidth / referenceTileWidth
        property real tileAspectRatio: 1

        /* The positioning and scaling of the items in the carousel is based on the variable
           'continuousIndex', a continuous real variable between [0, 'carousel.model.count'],
           roughly representing the index of the item that is prioritised over the others.
           'continuousIndex' is not linear, but is weighted depending on if it is close
           to the beginning of the content (beginning phase), in the middle (middle phase)
           or at the end (end phase).
           Each tile is scaled and transformed in proportion to the difference between
           its own index and continuousIndex.
           To efficiently calculate continuousIndex, we have these values:
            - 'gapToMiddlePhase' gap in pixels between beginning and middle phase
            - 'gapToEndPhase' gap in pixels between middle and end phase
            - 'kGapEnd' constant used to calculate 'continuousIndex' in end phase
            - 'kMiddleIndex' constant used to calculate 'continuousIndex' in middle phase
            - 'kXBeginningEnd' constant used to calculate 'continuousIndex' in beginning and end phase
            - 'realContentWidth' the width of all the delegates only (without header/footer)
            - 'realContentX' the 'contentX' of the listview ignoring the 'drawBuffer'
            - 'realWidth' the 'width' of the listview, as it is used as component. */

        readonly property real gapToMiddlePhase: Math.min(realWidth / 2 - tileWidth / 2, (realContentWidth - realWidth) / 2)
        readonly property real gapToEndPhase: realContentWidth - realWidth - gapToMiddlePhase
        readonly property real kGapEnd: kMiddleIndex * (1 - gapToEndPhase / gapToMiddlePhase)
        readonly property real kMiddleIndex: (realWidth / 2) / tileWidth - 0.5
        readonly property real kXBeginningEnd: 1 / tileWidth + kMiddleIndex / gapToMiddlePhase
        readonly property real maximumItemTranslation: (listView.tileWidth * 3) / listView.scaleFactor
        readonly property real disabledNewContentX: -carousel.drawBuffer - 1
        readonly property real realContentWidth: contentWidth - 2 * carousel.drawBuffer
        readonly property real realContentX: contentX + carousel.drawBuffer
        readonly property real realPathItemCount: Math.min(realWidth / tileWidth, pathItemCount)
        readonly property real realWidth: carousel.width
        readonly property real referenceGapToMiddlePhase: realWidth / 2 - tileWidth / 2
        readonly property real referencePathItemCount: referenceWidth / referenceTileWidth
        readonly property real referenceWidth: 848
        readonly property real referenceTileWidth: 175
        readonly property real scaleFactor: tileWidth / referenceTileWidth
        readonly property real tileWidth: Math.max(realWidth / pathItemCount, minimumTileWidth)
        readonly property real tileHeight: tileWidth / tileAspectRatio
        readonly property real translationXViewFactor: 0.2 * (referenceGapToMiddlePhase / gapToMiddlePhase)
        readonly property real verticalMargin: (parent.height - tileHeight - carousel.extraBottomMargin) / 2
        readonly property real visibleTilesScaleFactor: realPathItemCount / referencePathItemCount

        anchors {
            fill: parent
            topMargin: verticalMargin
            bottomMargin: verticalMargin + carousel.extraBottomMargin
            // extending the "drawing area"
            leftMargin: -carousel.drawBuffer
            rightMargin: -carousel.drawBuffer
        }

        /* The header and footer help to "extend" the area, the listview draws items.
           This together with anchors.leftMargin and anchors.rightMargin. */
        header: Item {
            width: carousel.drawBuffer
            height: listView.tileHeight
        }
        footer: Item {
            width: carousel.drawBuffer
            height: listView.tileHeight
        }

        boundsBehavior: Flickable.DragOverBounds
        cacheBuffer: carousel.cacheBuffer
        flickDeceleration: Math.max(1500 * Math.pow(realWidth / referenceWidth, 1.5), 1500) // 1500 is platform default
        maximumFlickVelocity: Math.max(2500 * Math.pow(realWidth / referenceWidth, 1.5), 2500) // 2500 is platform default
        orientation: ListView.Horizontal

        function getXFromContinuousIndex(index) {
            return CarouselJS.getXFromContinuousIndex(index,
                                                       realWidth,
                                                       footerItem.x,
                                                       tileWidth,
                                                       gapToMiddlePhase,
                                                       gapToEndPhase,
                                                       carousel.drawBuffer)
        }

        function itemClicked(index, delegateItem) {
            listView.currentIndex = index
            var x = getXFromContinuousIndex(index);

            if (Math.abs(x - contentX) < 1 && delegateItem !== undefined) {
                /* We're clicking the selected item and
                   we're in the neighbourhood of radius 1 pixel from it.
                   Let's emit the clicked signal. */
                delegateItem.clicked()
                return
            }

            stepAnimation.stop()
            newContentXAnimation.stop()

            newContentX = x
            newContentXAnimation.start()
        }

        function itemPressAndHold(index, delegateItem) {
            var x = getXFromContinuousIndex(index);

            if (Math.abs(x - contentX) < 1 && delegateItem !== undefined) {
                /* We're pressAndHold the selected item and
                   we're in the neighbourhood of radius 1 pixel from it.
                   Let's emit the pressAndHold signal. */
                delegateItem.pressAndHold();
                return;
            }

            stepAnimation.stop();
            newContentXAnimation.stop();

            newContentX = x;
            newContentXAnimation.start();
        }

        onHighlightIndexChanged: {
            if (highlightIndex != -1) {
                itemClicked(highlightIndex)
            }
        }

        onMovementStarted: {
            stepAnimation.stop()
            newContentXAnimation.stop()
            newContentX = disabledNewContentX
        }
        onMovementEnded: {
            if (realContentX > 0)
                stepAnimation.start()
        }

        SmoothedAnimation {
            id: stepAnimation
            objectName: "stepAnimation"

            target: listView
            property: "contentX"
            to: listView.getXFromContinuousIndex(listView.selectedIndex)
            duration: 450
            velocity: 200
            easing.type: Easing.InOutQuad
        }

        SequentialAnimation {
            id: newContentXAnimation

            NumberAnimation {
                target: listView
                property: "contentX"
                from: listView.contentX
                to: listView.newContentX
                duration: 300
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: listView.newContentX = listView.disabledNewContentX
            }
        }

        readonly property int selectedIndex: Math.round(continuousIndex)
        readonly property real continuousIndex: CarouselJS.getContinuousIndex(listView.realContentX,
                                                                              listView.tileWidth,
                                                                              listView.gapToMiddlePhase,
                                                                              listView.gapToEndPhase,
                                                                              listView.kGapEnd,
                                                                              listView.kMiddleIndex,
                                                                              listView.kXBeginningEnd)

        property real viewTranslation: CarouselJS.getViewTranslation(listView.realContentX,
                                                                     listView.tileWidth,
                                                                     listView.gapToMiddlePhase,
                                                                     listView.gapToEndPhase,
                                                                     listView.translationXViewFactor)

        delegate: tileWidth > 0 && tileHeight > 0 ? loaderComponent : null

        Component {
            id: loaderComponent

            Loader {
                property bool explicitlyScaled: explicitScaleFactor == carousel.selectedItemScaleFactor
                property real explicitScaleFactor: explicitScale ? carousel.selectedItemScaleFactor : 1.0
                readonly property bool explicitScale: (!listView.moving ||
                                                    listView.realContentX <= 0 ||
                                                    listView.realContentX >= listView.realContentWidth - listView.realWidth) &&
                                                    listView.newContentX === listView.disabledNewContentX &&
                                                    index === listView.selectedIndex
                readonly property real cachedTiles: listView.realPathItemCount + carousel.drawBuffer / listView.tileWidth
                readonly property real distance: listView.continuousIndex - index
                readonly property real itemTranslationScale: CarouselJS.getItemScale(0.5,
                                                                                    (index + 0.5), // good approximation of scale while changing selected item
                                                                                    listView.count,
                                                                                    listView.visibleTilesScaleFactor)
                readonly property real itemScale: CarouselJS.getItemScale(distance,
                                                                        listView.continuousIndex,
                                                                        listView.count,
                                                                        listView.visibleTilesScaleFactor)
                readonly property real translationX: CarouselJS.getItemTranslation(index,
                                                                                listView.selectedIndex,
                                                                                distance,
                                                                                itemScale,
                                                                                itemTranslationScale,
                                                                                listView.maximumItemTranslation)

                readonly property real xTransform: listView.viewTranslation + translationX * listView.scaleFactor
                readonly property real center: x - listView.contentX + xTransform - drawBuffer + (width/2)

                width: listView.tileWidth
                height: listView.tileHeight
                scale: itemScale * explicitScaleFactor
                sourceComponent: itemComponent
                z: cachedTiles - Math.abs(index - listView.selectedIndex)

                transform: Translate {
                    x: xTransform
                }

                Behavior on explicitScaleFactor {
                    SequentialAnimation {
                        ScriptAction {
                            script: if (!explicitScale)
                                        explicitlyScaled = false
                        }
                        NumberAnimation {
                            duration: explicitScaleFactor === 1.0 ? 250 : 150
                            easing.type: Easing.InOutQuad
                        }
                        ScriptAction {
                            script: if (explicitScale)
                                        explicitlyScaled = true
                        }
                    }
                }

                onLoaded: {
                    item.explicitlyScaled = Qt.binding(function() { return explicitlyScaled; });
                    item.index = Qt.binding(function() { return index; });
                    item.model = Qt.binding(function() { return model; });
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    onClicked: {
                        listView.itemClicked(index, item)
                    }

                    onPressAndHold: {
                        listView.itemPressAndHold(index, item)
                    }
                }
            }
        }
    }
}
