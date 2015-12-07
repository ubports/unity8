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
import Utils 0.1
import Unity 0.2
import Dash 0.1
import "../Components"
import "../Components/ListItems" as ListItems

FocusScope {
    id: scopeView

    readonly property bool navigationDisableParentInteractive: pageHeaderLoader.item ? pageHeaderLoader.item.bottomItem[0].disableParentInteractive : false
    property bool forceNonInteractive: false
    property var scope: null
    property UnitySortFilterProxyModel categories: categoryFilter
    property bool isCurrent: false
    property alias moving: categoryView.moving
    property bool hasBackAction: false
    property bool enableHeightBehaviorOnNextCreation: false
    property var categoryView: categoryView
    property bool showPageHeader: true
    readonly property alias subPageShown: subPageLoader.subPageShown
    property int paginationCount: 0
    property int paginationIndex: 0
    property bool visibleToParent: false
    property alias pageHeaderTotallyVisible: categoryView.pageHeaderTotallyVisible
    property var holdingList: null
    property bool wasCurrentOnMoveStart: false

    property var scopeStyle: ScopeStyle {
        style: scope ? scope.customizations : {}
    }

    readonly property bool processing: scope ? scope.searchInProgress || subPageLoader.processing : false

    signal backClicked()

    onScopeChanged: {
        floatingSeeLess.companionBase = null;
    }

    function positionAtBeginning() {
        categoryView.positionAtBeginning()
    }

    function showHeader() {
        categoryView.showHeader()
    }

    function closePreview() {
        subPageLoader.closeSubPage()
    }

    function resetSearch() {
        if(pageHeaderLoader.item && showPageHeader)
            pageHeaderLoader.item.resetSearch()
    }

    property var maybePreviewResult;
    property int maybePreviewIndex;
    property var maybePreviewResultsModel;
    property int maybePreviewLimitedCategoryItemCount;
    property string maybePreviewCategoryId;

    function clearMaybePreviewData() {
        scopeView.maybePreviewResult = undefined;
        scopeView.maybePreviewIndex = -1;
        scopeView.maybePreviewResultsModel = undefined;
        scopeView.maybePreviewLimitedCategoryItemCount = -1;
        scopeView.maybePreviewCategoryId = "";
    }

    function itemClicked(index, result, itemModel, resultsModel, limitedCategoryItemCount, categoryId) {
        scopeView.maybePreviewResult = result;
        scopeView.maybePreviewIndex = index;
        scopeView.maybePreviewResultsModel = resultsModel;
        scopeView.maybePreviewLimitedCategoryItemCount = limitedCategoryItemCount;
        scopeView.maybePreviewCategoryId = categoryId;

        scope.activate(result, categoryId);
    }

    function itemPressedAndHeld(index, result, resultsModel, limitedCategoryItemCount, categoryId) {
        clearMaybePreviewData();

        openPreview(result, index, resultsModel, limitedCategoryItemCount, categoryId);
    }

    function openPreview(result, index, resultsModel, limitedCategoryItemCount, categoryId) {
        var previewStack = scope.preview(result, categoryId);
        if (previewStack) {
            if (limitedCategoryItemCount > 0) {
                previewLimitModel.model = resultsModel;
                previewLimitModel.limit = limitedCategoryItemCount;
                subPageLoader.model = previewLimitModel;
            } else {
                subPageLoader.model = resultsModel;
            }
            subPageLoader.initialIndex = -1;
            subPageLoader.initialIndex = index;
            subPageLoader.categoryId = categoryId;
            subPageLoader.previewStack = previewStack;
            subPageLoader.openSubPage("preview");
        }
    }

    Binding {
        target: scope
        property: "isActive"
        value: isCurrent && !subPageLoader.open && (Qt.application.state == Qt.ApplicationActive)
    }

    UnitySortFilterProxyModel {
        id: categoryFilter
        model: scope ? scope.categories : null
        dynamicSortFilter: true
        filterRole: Categories.RoleCount
        filterRegExp: /^0$/
        invertMatch: true
    }

    onIsCurrentChanged: {
        if (!holdingList || !holdingList.moving) {
            wasCurrentOnMoveStart = scopeView.isCurrent;
        }
        if (pageHeaderLoader.item && showPageHeader) {
            pageHeaderLoader.item.resetSearch();
        }
        subPageLoader.closeSubPage();
    }

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeaderLoader.item ? pageHeaderLoader.item.searchQuery : ""
        when: isCurrent && showPageHeader
    }

    Binding {
        target: pageHeaderLoader.item
        property: "searchQuery"
        value: scopeView.scope ? scopeView.scope.searchQuery : ""
        when: isCurrent && showPageHeader
    }

    Connections {
        target: scopeView.scope
        onShowDash: subPageLoader.closeSubPage()
        onHideDash: subPageLoader.closeSubPage()
        onPreviewRequested: { // (QVariant const& result)
            if (result === scopeView.maybePreviewResult) {
                openPreview(result,
                            scopeView.maybePreviewIndex,
                            scopeView.maybePreviewResultsModel,
                            scopeView.maybePreviewLimitedCategoryItemCount,
                            scopeView.maybePreviewCategoryId);

                clearMaybePreviewData();
            }
        }
    }

    Connections {
        target: holdingList
        onMovingChanged: {
            if (!moving) {
                wasCurrentOnMoveStart = scopeView.isCurrent;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: scopeView.scopeStyle ? scopeView.scopeStyle.background : "transparent"
        visible: color != "transparent"
    }

    ScopeListView {
        id: categoryView
        objectName: "categoryListView"
        interactive: !forceNonInteractive

        x: subPageLoader.open ? -width : 0
        visible: x != -width
        Behavior on x { UbuntuNumberAnimation { } }
        width: parent.width
        height: floatingSeeLess.visible ? parent.height - floatingSeeLess.height + floatingSeeLess.yOffset
                                        : parent.height
        clip: height != parent.height

        model: scopeView.categories
        forceNoClip: subPageLoader.open
        pixelAligned: true

        property string expandedCategoryId: ""
        property int runMaximizeAfterSizeChanges: 0

        readonly property bool pageHeaderTotallyVisible: scopeView.showPageHeader &&
            ((headerItemShownHeight == 0 && categoryView.contentY <= categoryView.originY) || (headerItemShownHeight == pageHeaderLoader.item.height))

        onExpandedCategoryIdChanged: {
            var firstCreated = firstCreatedIndex();
            var shrinkingAny = false;
            var shrinkHeightDifference = 0;
            for (var i = 0; i < createdItemCount(); ++i) {
                var baseItem = item(firstCreated + i);
                if (baseItem.expandable) {
                    var shouldExpand = baseItem.category === expandedCategoryId;
                    if (shouldExpand != baseItem.expanded) {
                        var animate = false;
                        if (!subPageLoader.open) {
                            var animateShrinking = !shouldExpand && baseItem.y + baseItem.item.collapsedHeight + baseItem.seeAllButton.height < categoryView.height;
                            var animateGrowing = shouldExpand && baseItem.y + baseItem.height < categoryView.height;
                            animate = shrinkingAny || animateShrinking || animateGrowing;
                        }

                        if (!shouldExpand) {
                            shrinkingAny = true;
                            shrinkHeightDifference = baseItem.item.expandedHeight - baseItem.item.collapsedHeight;
                        }

                        if (shouldExpand && !subPageLoader.open) {
                            if (!shrinkingAny) {
                                categoryView.maximizeVisibleArea(firstCreated + i, baseItem.item.expandedHeight + baseItem.seeAllButton.height);
                            } else {
                                // If the space that shrinking is smaller than the one we need to grow we'll call maximizeVisibleArea
                                // after the shrink/grow animation ends
                                var growHeightDifference = baseItem.item.expandedHeight - baseItem.item.collapsedHeight;
                                if (growHeightDifference > shrinkHeightDifference) {
                                    runMaximizeAfterSizeChanges = 2;
                                } else {
                                    runMaximizeAfterSizeChanges = 0;
                                }
                            }
                        }

                        baseItem.expand(shouldExpand, animate);
                    }
                }
            }
        }

        delegate: DashCategoryBase {
            id: baseItem
            objectName: "dashCategory" + category

            property Item seeAllButton: seeAll

            readonly property bool expandable: {
                if (categoryView.model.count === 1) return false;
                if (cardTool.template && cardTool.template["collapsed-rows"] === 0) return false;
                if (item && item.expandedHeight > item.collapsedHeight) return true;
                return false;
            }
            property bool expanded: false
            readonly property string category: categoryId
            readonly property string headerLink: model.headerLink
            readonly property var item: rendererLoader.item

            function expand(expand, animate) {
                heightBehaviour.enabled = animate;
                expanded = expand;
            }

            CardTool {
                id: cardTool
                objectName: "cardTool"
                count: results ? results.count : 0
                template: model.renderer
                components: model.components
                viewWidth: parent.width
            }

            onExpandableChanged: {
                // This can happen with the VJ that doesn't know how height it will be on creation
                // so doesn't set expandable until a bit too late for onLoaded
                if (expandable) {
                    var shouldExpand = baseItem.category === categoryView.expandedCategoryId;
                    baseItem.expand(shouldExpand, false /*animate*/);
                }
            }

            onHeightChanged: rendererLoader.updateRanges();
            onYChanged: rendererLoader.updateRanges();

            Loader {
                id: rendererLoader
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: name != "" ? 0 : units.gu(2)
                }

                Behavior on height {
                    id: heightBehaviour
                    enabled: false
                    animation: UbuntuNumberAnimation {
                        duration: UbuntuAnimation.FastDuration
                        onRunningChanged: {
                            if (!running) {
                                heightBehaviour.enabled = false
                                if (categoryView.runMaximizeAfterSizeChanges > 0) {
                                    categoryView.runMaximizeAfterSizeChanges--;
                                    if (categoryView.runMaximizeAfterSizeChanges == 0) {
                                        var firstCreated = categoryView.firstCreatedIndex();
                                        for (var i = 0; i < categoryView.createdItemCount(); ++i) {
                                            var baseItem = categoryView.item(firstCreated + i);
                                            if (baseItem.category === categoryView.expandedCategoryId) {
                                                categoryView.maximizeVisibleArea(firstCreated + i, baseItem.item.expandedHeight + baseItem.seeAllButton.height);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                readonly property bool expanded: baseItem.expanded || !baseItem.expandable
                height: expanded ? item.expandedHeight : item.collapsedHeight

                source: {
                    switch (cardTool.categoryLayout) {
                        case "carousel": return "CardCarousel.qml";
                        case "vertical-journal": return "CardVerticalJournal.qml";
                        case "horizontal-list": return "CardHorizontalList.qml";
                        case "grid":
                        default: return "CardGrid.qml";
                    }
                }

                onLoaded: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        item.enableHeightBehavior = scopeView.enableHeightBehaviorOnNextCreation;
                        scopeView.enableHeightBehaviorOnNextCreation = false;
                    }
                    item.model = Qt.binding(function() { return results })
                    item.objectName = Qt.binding(function() { return categoryId })
                    item.scopeStyle = scopeView.scopeStyle;
                    if (baseItem.expandable) {
                        var shouldExpand = baseItem.category === categoryView.expandedCategoryId;
                        baseItem.expand(shouldExpand, false /*animate*/);
                    }
                    updateRanges();
                    if (scope && scope.id === "clickscope" && (categoryId === "predefined" || categoryId === "local")) {
                        // Yeah, hackish :/
                        if (scopeView.width > units.gu(45)) {
                            if (scopeView.width >= units.gu(70)) {
                                cardTool.cardWidth = units.gu(9);
                            } else {
                                cardTool.cardWidth = units.gu(10);
                            }
                        }
                        cardTool.artShapeSize = Qt.size(units.gu(8), units.gu(7.5));
                        item.artShapeStyle = "icon";
                    }
                    item.cardTool = cardTool;
                }

                Component.onDestruction: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        scopeView.enableHeightBehaviorOnNextCreation = item.enableHeightBehaviorOnNextCreation;
                    }
                }

                Connections {
                    target: rendererLoader.item
                    onClicked: { // (int index, var result, var item, var itemModel)
                        scopeView.itemClicked(index, result, itemModel, target.model, categoryItemCount(), baseItem.category);
                    }

                    onPressAndHold: { // (int index, var result, var itemModel)
                        scopeView.itemPressedAndHeld(index, result, target.model, categoryItemCount(), baseItem.category);
                    }

                    function categoryItemCount() {
                        var categoryItemCount = -1;
                        if (!rendererLoader.expanded && !seeAllLabel.visible && target.collapsedItemCount > 0) {
                            categoryItemCount = target.collapsedItemCount;
                        }
                        return categoryItemCount;
                    }
                }
                Connections {
                    target: categoryView
                    onOriginYChanged: rendererLoader.updateRanges();
                    onContentYChanged: rendererLoader.updateRanges();
                    onHeightChanged: rendererLoader.updateRanges();
                    onContentHeightChanged: rendererLoader.updateRanges();
                }
                Connections {
                    target: scopeView
                    onIsCurrentChanged: rendererLoader.updateRanges();
                    onVisibleToParentChanged: rendererLoader.updateRanges();
                }
                Connections {
                    target: holdingList
                    onMovingChanged: if (!moving) rendererLoader.updateRanges();
                }

                function updateRanges() {
                    // Don't want to create stress by requesting more items during scope
                    // changes so unless you're not part of the visible scopes just return.
                    // For the visible scopes we need to do some work, the previously non visible
                    // scope needs to adjust its ranges so that we define the new visible range,
                    // that still means no creation/destruction of delegates, it's just about changing
                    // the culling of the items so they are actually visible
                    if (holdingList && holdingList.moving && !scopeView.visibleToParent) {
                        return;
                    }

                    if (categoryView.moving) {
                        // Do not update the range if we are overshooting up or down, since we'll come back
                        // to the stable position and delete/create items without any reason
                        if (categoryView.contentY < categoryView.originY) {
                            return;
                        } else if (categoryView.contentHeight - categoryView.originY > categoryView.height &&
                                   categoryView.contentY + categoryView.height > categoryView.contentHeight) {
                            return;
                        }
                    }

                    if (item && item.hasOwnProperty("displayMarginBeginning")) {
                        var buffer = wasCurrentOnMoveStart ? categoryView.height * 1.5 : 0;
                        var onViewport = baseItem.y + baseItem.height > 0 &&
                                         baseItem.y < categoryView.height;
                        var onBufferViewport = baseItem.y + baseItem.height > -buffer &&
                                               baseItem.y < categoryView.height + buffer;

                        if (item.growsVertically) {
                            // A item view creates its delegates synchronously from
                            //     -displayMarginBeginning
                            // to
                            //     height + displayMarginEnd
                            // Around that area it adds the cacheBuffer area where delegates are created async
                            //
                            // We adjust displayMarginBeginning and displayMarginEnd so
                            //   * In non visible scopes nothing is considered visible and we set cacheBuffer
                            //     so that creates the items that would be in the viewport asynchronously
                            //   * For the current scope set the visible range to the viewport and then
                            //     use cacheBuffer to create extra items for categoryView.height * 1.5
                            //     to make scrolling nicer by mantaining a higher number of
                            //     cached items
                            //   * For non current but visible scopes (i.e. when the user changes from one scope
                            //     to the next, we set the visible range to the viewport so
                            //     items are not culled (invisible) but still use no cacheBuffer
                            //     (it will be set once the scope is the current one)
                            var displayMarginBeginning = baseItem.y + rendererLoader.anchors.topMargin;
                            displayMarginBeginning = -Math.max(-displayMarginBeginning, 0);
                            displayMarginBeginning = -Math.min(-displayMarginBeginning, baseItem.height);
                            displayMarginBeginning = Math.round(displayMarginBeginning);
                            var displayMarginEnd = -baseItem.height + seeAll.height + categoryView.height - baseItem.y;
                            displayMarginEnd = -Math.max(-displayMarginEnd, 0);
                            displayMarginEnd = -Math.min(-displayMarginEnd, baseItem.height);
                            displayMarginEnd = Math.round(displayMarginEnd);

                            if (onBufferViewport && (scopeView.isCurrent || scopeView.visibleToParent)) {
                                item.displayMarginBeginning = displayMarginBeginning;
                                item.displayMarginEnd = displayMarginEnd;
                                if (holdingList && holdingList.moving) {
                                    // If we are moving we need to reset the cache buffer of the
                                    // view that was not visible (i.e. !wasCurrentOnMoveStart) to 0 since
                                    // otherwise the cache buffer we had set to preload the items of the
                                    // visible range will trigger some item creations and we want move to
                                    // be as smooth as possible meaning no need creations
                                    if (!wasCurrentOnMoveStart) {
                                        item.cacheBuffer = 0;
                                    }
                                } else {
                                    // Protect us against cases where the item hasn't yet been positioned
                                    if (!(categoryView.contentY === 0 && baseItem.y === 0 && index !== 0)) {
                                        item.cacheBuffer = categoryView.height * 1.5;
                                    }
                                }
                            } else {
                                var visibleRange = baseItem.height + displayMarginEnd + displayMarginBeginning;
                                if (visibleRange < 0) {
                                    item.displayMarginBeginning = displayMarginBeginning;
                                    item.displayMarginEnd = displayMarginEnd;
                                    item.cacheBuffer = 0;
                                } else {
                                    // This should be visibleRange/2 in each of the properties
                                    // but some item views still (like GridView) like creating sync delegates even if
                                    // the visible range is 0 so let's make sure the visible range is negative
                                    item.displayMarginBeginning = displayMarginBeginning - visibleRange;
                                    item.displayMarginEnd = displayMarginEnd - visibleRange;
                                    item.cacheBuffer = visibleRange;
                                }
                            }
                        } else {
                            if (!onBufferViewport) {
                                // If not on the buffered viewport, don't load anything
                                item.displayMarginBeginning = 0;
                                item.displayMarginEnd = -item.innerWidth;
                                item.cacheBuffer = 0;
                            } else {
                                if (onViewport && (scopeView.isCurrent || scopeView.visibleToParent)) {
                                    // If on the buffered viewport and the viewport and the on a visible scope
                                    // Set displayMargin so that cards are rendered
                                    // And if not moving the parent list also give it some extra asynchronously
                                    // buffering
                                    item.displayMarginBeginning = 0;
                                    item.displayMarginEnd = 0;
                                    if (holdingList && holdingList.moving) {
                                        // If we are moving we need to reset the cache buffer of the
                                        // view that was not visible (i.e. !wasCurrentOnMoveStart) to 0 since
                                        // otherwise the cache buffer we had set to preload the items of the
                                        // visible range will trigger some item creations and we want move to
                                        // be as smooth as possible meaning no need creations
                                        if (!wasCurrentOnMoveStart) {
                                            item.cacheBuffer = 0;
                                        }
                                    } else {
                                        item.cacheBuffer = baseItem.width * 1.5;
                                    }
                                } else {
                                    // If on the buffered viewport but either not in the real viewport
                                    // or in the viewport of the non current scope, use displayMargin + cacheBuffer
                                    // to render asynchronously the width of cards
                                    item.displayMarginBeginning = 0;
                                    item.displayMarginEnd = -item.innerWidth;
                                    item.cacheBuffer = item.innerWidth;
                                }
                            }
                        }
                    }
                }
            }

            AbstractButton {
                id: seeAll
                objectName: "seeAll"
                anchors {
                    top: rendererLoader.bottom
                    left: parent.left
                    right: parent.right
                }
                height: baseItem.expandable && !baseItem.headerLink ? seeAllLabel.font.pixelSize + units.gu(4) : 0
                visible: height != 0

                onClicked: {
                    if (categoryView.expandedCategoryId !== baseItem.category) {
                        categoryView.expandedCategoryId = baseItem.category;
                        floatingSeeLess.companionBase = baseItem;
                    } else {
                        categoryView.expandedCategoryId = "";
                    }
                }

                Label {
                    id: seeAllLabel
                    text: baseItem.expanded ? i18n.tr("See less") : i18n.tr("See all")
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: units.gu(-0.5)
                    }
                    fontSize: "small"
                    font.weight: Font.Bold
                    color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
                }
            }

            Image {
                visible: index != 0
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                fillMode: Image.Stretch
                source: "graphics/dash_divider_top_lightgrad.png"
                z: -1
            }

            Image {
                // FIXME Should not rely on model.count but view.count, but ListViewWithPageHeader doesn't expose it yet.
                visible: index != categoryView.model.count - 1
                anchors {
                    bottom: seeAll.bottom
                    left: parent.left
                    right: parent.right
                }
                fillMode: Image.Stretch
                source: "graphics/dash_divider_top_darkgrad.png"
                z: -1
            }
        }

        sectionProperty: "name"
        sectionDelegate: ListItems.Header {
            objectName: "dashSectionHeader" + (delegate ? delegate.category : "")
            readonly property var delegate: categoryView.item(delegateIndex)
            width: categoryView.width
            height: section != "" ? units.gu(5) : 0
            text: section
            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
            iconName: delegate && delegate.headerLink ? "go-next" : ""
            onClicked: {
                if (delegate.headerLink) scopeView.scope.performQuery(delegate.headerLink);
            }
        }

        pageHeader: scopeView.showPageHeader ? pageHeaderLoader : null
        Loader {
            id: pageHeaderLoader
            width: parent.width
            sourceComponent: scopeView.showPageHeader ? pageHeaderComponent : undefined
            Component {
                id: pageHeaderComponent
                DashPageHeader {
                    objectName: "scopePageHeader"
                    width: parent.width
                    title: scopeView.scope ? scopeView.scope.name : ""
                    searchHint: scopeView.scope && scopeView.scope.searchHint || i18n.ctr("Label: Hint for dash search line edit", "Search")
                    showBackButton: scopeView.hasBackAction
                    searchEntryEnabled: true
                    settingsEnabled: scopeView.scope && scopeView.scope.settings && scopeView.scope.settings.count > 0 || false
                    favoriteEnabled: scopeView.scope && scopeView.scope.id !== "clickscope"
                    favorite: scopeView.scope && scopeView.scope.favorite
                    scopeStyle: scopeView.scopeStyle
                    paginationCount: scopeView.paginationCount
                    paginationIndex: scopeView.paginationIndex

                    bottomItem: DashNavigation {
                        scope: scopeView.scope
                        anchors { left: parent.left; right: parent.right }
                        windowHeight: scopeView.height
                        windowWidth: scopeView.width
                        scopeStyle: scopeView.scopeStyle
                    }

                    onBackClicked: scopeView.backClicked()
                    onSettingsClicked: subPageLoader.openSubPage("settings")
                    onFavoriteClicked: scopeView.scope.favorite = !scopeView.scope.favorite
                    onSearchTextFieldFocused: scopeView.showHeader()
                }
            }
        }
    }

    Item {
        id: pullToRefreshClippingItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height - pullToRefresh.contentY + (pageHeaderLoader.item ? pageHeaderLoader.item.bottomItem[0].height - pageHeaderLoader.item.height : 0)
        clip: true

        PullToRefresh {
            id: pullToRefresh
            objectName: "pullToRefresh"
            target: categoryView

            readonly property real contentY: categoryView.contentY - categoryView.originY
            y: -contentY - units.gu(5)

            onRefresh: {
                refreshing = true
                scopeView.scope.refresh()
            }
            anchors.left: parent.left
            anchors.right: parent.right

            Connections {
                target: scopeView
                onProcessingChanged: if (!scopeView.processing) pullToRefresh.refreshing = false
            }

            style: PullToRefreshScopeStyle {
                anchors.fill: parent
                activationThreshold: units.gu(14)
            }
        }
    }

    AbstractButton {
        id: floatingSeeLess
        objectName: "floatingSeeLess"

        property Item companionTo: companionBase ? companionBase.seeAllButton : null
        property Item companionBase: null
        property bool showBecausePosition: false
        property real yOffset: 0

        anchors {
            left: categoryView.left
            right: categoryView.right
        }
        y: parent.height - height + yOffset
        height: seeLessLabel.font.pixelSize + units.gu(4)
        visible: companionTo && showBecausePosition

        onClicked: categoryView.expandedCategoryId = "";

        function updateVisibility() {
            var companionPos = companionTo.mapToItem(floatingSeeLess, 0, 0);
            showBecausePosition = companionPos.y > 0;

            var posToBase = floatingSeeLess.mapToItem(companionBase, 0, -yOffset).y;
            yOffset = Math.max(0, companionBase.item.collapsedHeight - posToBase);
            yOffset = Math.min(yOffset, height);

            if (!showBecausePosition && categoryView.expandedCategoryId === "") {
                companionBase = null;
            }
        }

        Label {
            id: seeLessLabel
            text: i18n.tr("See less")
            anchors {
                centerIn: parent
                verticalCenterOffset: units.gu(-0.5)
            }
            fontSize: "small"
            font.weight: Font.Bold
            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
        }

        Connections {
            target: floatingSeeLess.companionTo ? categoryView : null
            onContentYChanged: floatingSeeLess.updateVisibility();
        }

        Connections {
            target: floatingSeeLess.companionTo
            onYChanged: floatingSeeLess.updateVisibility();
        }
    }

    LimitProxyModel {
        id: previewLimitModel
    }

    Loader {
        id: subPageLoader
        objectName: "subPageLoader"
        visible: x != width
        width: parent.width
        height: parent.height
        anchors.left: categoryView.right

        property bool open: false
        property var scope: scopeView.scope
        property var scopeStyle: scopeView.scopeStyle
        property int initialIndex: -1
        property var previewStack;
        property string categoryId
        property var model: null

        readonly property bool processing: item && item.processing || false
        readonly property int count: item && item.count || 0
        readonly property int currentIndex: item && item.currentIndex || 0
        readonly property var currentItem: item && item.currentItem || null

        property string subPage: ""
        readonly property bool subPageShown: visible && status === Loader.Ready

        function openSubPage(page) {
            subPage = page;
        }

        function closeSubPage() {
            open = false;
        }

        source: switch(subPage) {
            case "preview": return "PreviewListView.qml";
            case "settings": return "ScopeSettingsPage.qml";
            default: return "";
        }

        onLoaded: {
            item.scope = Qt.binding(function() { return subPageLoader.scope; } )
            item.scopeStyle = Qt.binding(function() { return subPageLoader.scopeStyle; } )
            if (subPage == "preview") {
                item.open = Qt.binding(function() { return subPageLoader.open; } )
                item.initialIndex = Qt.binding(function() { return subPageLoader.initialIndex; } )
                item.model = Qt.binding(function() { return subPageLoader.model; } )
                item.categoryId = Qt.binding(function() { return subPageLoader.categoryId; } )
                item.initialIndexPreviewStack = subPageLoader.previewStack;
                subPageLoader.previewStack = null;
            }
            open = true;
        }

        onOpenChanged: pageHeaderLoader.item.unfocus()

        onVisibleChanged: if (!visible) subPage = ""

        Connections {
            target: subPageLoader.item
            onBackClicked: subPageLoader.closeSubPage()
        }
    }
}
