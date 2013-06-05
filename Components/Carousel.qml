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
import "carousel.js" as CarouselJS

Item {
    id: carousel

    property Component itemComponent
    property var model
    property alias minimumTileWidth: flickable.minimumTileWidth
    property alias pathItemCount: flickable.pathItemCount
    property alias tileAspectRatio: flickable.tileAspectRatio
    property int cacheBuffer: 0
    property real selectedItemScaleFactor: 1.1

    signal clicked(int index, var delegateItem, real itemY)

    implicitHeight: flickable.tileHeight * selectedItemScaleFactor

    /* TODO: evaluate if the component could be more efficient with a ListView,
             using this technique https://bugreports.qt-project.org/browse/QTBUG-29173 */

    Flickable {
        id: flickable

        property real minimumTileWidth: 0
        property real newContentX: -1
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
            - 'kXBeginningEnd' constant used to calculate 'continuousIndex' in beginning and end phase. */

        readonly property real gapToMiddlePhase: Math.min(width / 2 - tileWidth / 2, (contentWidth - width) / 2)
        readonly property real gapToEndPhase: contentWidth - width - gapToMiddlePhase
        readonly property real kGapEnd: kMiddleIndex * (1 - gapToEndPhase / gapToMiddlePhase)
        readonly property real kMiddleIndex: (width / 2) / tileWidth - 0.5
        readonly property real kXBeginningEnd: 1 / tileWidth + kMiddleIndex / gapToMiddlePhase
        readonly property real realPathItemCount: Math.min(width / tileWidth, pathItemCount)
        readonly property real referenceGapToMiddlePhase: width / 2 - tileWidth / 2
        readonly property real referencePathItemCount: referenceWidth / referenceTileWidth
        readonly property real referenceWidth: 848
        readonly property real referenceTileWidth: 175
        readonly property real scaleFactor: tileWidth / referenceTileWidth
        readonly property real tileWidth: Math.max(width / pathItemCount, minimumTileWidth)
        readonly property real tileHeight: tileWidth / tileAspectRatio
        readonly property real translationXViewFactor: 0.2 * (referenceGapToMiddlePhase / gapToMiddlePhase)
        readonly property real verticalMargin: (parent.height - tileHeight) / 2
        readonly property real visibleTilesScaleFactor: realPathItemCount / referencePathItemCount

        anchors {
            fill: parent
            topMargin: verticalMargin
            bottomMargin: verticalMargin
        }
        contentWidth: view.width
        contentHeight: height
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: Math.max(1500 * Math.pow(width / referenceWidth, 1.5), 1500) // 1500 is platform default
        maximumFlickVelocity: Math.max(2500 * Math.pow(width / referenceWidth, 1.5), 2500) // 2500 is platform default

        function itemClicked(index, delegateItem) {
            var x = CarouselJS.getXFromContinuousIndex(index,
                                                       width,
                                                       contentWidth,
                                                       tileWidth,
                                                       gapToMiddlePhase,
                                                       gapToEndPhase)

            if (Math.abs(x - contentX) < 1) {
                /* We're clicking the selected item and
                   we're in the neighbourhood of radius 1 pixel from it.
                   Let's emit the clicked signal. */
                carousel.clicked(index, delegateItem, delegateItem.y)
                return
            }

            stepAnimation.stop()
            newContentXAnimation.stop()

            newContentX = x
            newContentXAnimation.start()
        }

        onMovementStarted: {
            stepAnimation.stop()
            newContentXAnimation.stop()
            newContentX = -1
        }
        onMovementEnded: {
            if (contentX > 0 && contentX < contentWidth - width)
                stepAnimation.start()
        }

        SmoothedAnimation {
            id: stepAnimation

            target: flickable
            property: "contentX"
            from: flickable.contentX
            to: CarouselJS.getXFromContinuousIndex(view.selectedIndex,
                                                   flickable.width,
                                                   flickable.contentWidth,
                                                   flickable.tileWidth,
                                                   flickable.gapToMiddlePhase,
                                                   flickable.gapToEndPhase)
            duration: 450
            velocity: 200
            easing.type: Easing.InOutQuad
        }

        SequentialAnimation {
            id: newContentXAnimation

            NumberAnimation {
                target: flickable
                property: "contentX"
                from: flickable.contentX
                to: flickable.newContentX
                duration: 300
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: flickable.newContentX = -1
            }
        }

        Row {
            id: view

            readonly property int selectedIndex: Math.round(continuousIndex)
            readonly property real continuousIndex: CarouselJS.getContinuousIndex(flickable.contentX,
                                                                                  flickable.tileWidth,
                                                                                  flickable.gapToMiddlePhase,
                                                                                  flickable.gapToEndPhase,
                                                                                  flickable.kGapEnd,
                                                                                  flickable.kMiddleIndex,
                                                                                  flickable.kXBeginningEnd)

            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            transform: Translate {
                x: CarouselJS.getViewTranslation(flickable.contentX,
                                                 flickable.tileWidth,
                                                 flickable.gapToMiddlePhase,
                                                 flickable.gapToEndPhase,
                                                 flickable.translationXViewFactor)
            }

            Repeater {
                id: repeater

                model: carousel.model

                Loader {
                    property bool explicitlyScaled: explicitScaleFactor == carousel.selectedItemScaleFactor
                    property real explicitScaleFactor: explicitScale ? carousel.selectedItemScaleFactor : 1.0
                    readonly property bool explicitScale: (!flickable.moving ||
                                                           flickable.contentX <= 0 ||
                                                           flickable.contentX >= flickable.contentWidth - flickable.width) &&
                                                          flickable.newContentX < 0 &&
                                                          index === view.selectedIndex
                    readonly property real cachedTiles: flickable.realPathItemCount + carousel.cacheBuffer / flickable.tileWidth
                    readonly property real distance: view.continuousIndex - index
                    readonly property real itemTranslationScale: CarouselJS.getItemScale(0.5,
                                                                                         (index + 0.5), // good approximation of scale while changing selected item
                                                                                         repeater.count,
                                                                                         flickable.visibleTilesScaleFactor)
                    readonly property real itemScale: CarouselJS.getItemScale(distance,
                                                                              view.continuousIndex,
                                                                              repeater.count,
                                                                              flickable.visibleTilesScaleFactor)
                    readonly property real translationFactor: (flickable.tileWidth * 3) / flickable.scaleFactor
                    readonly property real translationX: index === view.selectedIndex ? 0 :
                                                         CarouselJS.getItemTranslation(distance,
                                                                                       itemScale,
                                                                                       itemTranslationScale,
                                                                                       translationFactor)

                    width: flickable.tileWidth
                    height: flickable.tileHeight
                    scale: itemScale * explicitScaleFactor
                    opacity: scale > 0.02 ? 1 : 0
                    sourceComponent: z > 0 ? itemComponent : undefined
                    z: cachedTiles - Math.abs(index - view.selectedIndex)

                    transform: Translate {
                        x: translationX * flickable.scaleFactor
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
                        item.explicitlyScaled = Qt.binding(function() { return explicitlyScaled; })
                        item.model = Qt.binding(function() { return model; })
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent

                        onClicked: flickable.itemClicked(index, item)
                    }
                }
            }
        }
    }
}
