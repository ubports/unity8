/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import ".."
import "../../../qml/Hud"
import HudClient 0.1
import Unity.Test 0.1 as UT

Hud {
    id: hud
    height: units.gu(80)
    width: units.gu(50)

    // Mock shell to shut up some warnings
    property QtObject shell: QtObject {
        property QtObject applicationManager: QtObject {
            id: applicationManager
            property bool keyboardVisible: false
        }
    }

    HudClientStub {
        id: hudClientStub
    }

    UT.UnityTestCase {
        name: "Hud"
        when: windowShown

        function resetToInitialState() {
            var parametrizedActionsPage = findChild(hud, "parametrizedActionsPage")

            hud.show()
            hud.resetToInitialState()
            hudClientStub.reset()
            tryCompare(parametrizedActionsPage, "x", hud.width) // Make sure the parametrized page action animation is finished
        }

        function test_hud_toolbar() {
            var toolBar = findChild(hud, "toolBar")
            resetToInitialState()

            var toolBarIconCount = 0
            for (var i in toolBar.children) {
                if (UT.Util.isInstanceOf(toolBar.children[i], "ToolBarIcon")) {
                    toolBarIconCount++
                }
            }
            compare(toolBarIconCount, 4, "toolbar item count")

            mouseClick(toolBar.children[0], 0, 0)
            compare(hudClientStub.lastExecutedToolbarItem, hudClientStub.undoToolbarItemValue(), "Click on undo")

            mouseClick(toolBar.children[1], 0, 0)
            compare(hudClientStub.lastExecutedToolbarItem, hudClientStub.helpToolbarItemValue(), "Click on help")

            mouseClick(toolBar.children[2], 0, 0)
            compare(hudClientStub.lastExecutedToolbarItem, hudClientStub.fullScreenToolbarItemValue(), "Click on fullscreen")

            mouseClick(toolBar.children[3], 0, 0)
            compare(hudClientStub.lastExecutedToolbarItem, hudClientStub.preferencesToolbarItemValue(), "Click on preferences")

            compare(toolBar.children[0].enabled, true)
            compare(toolBar.children[1].enabled, true)
            compare(toolBar.children[2].enabled, true)
            compare(toolBar.children[3].enabled, true)

            hudClientStub.setHelpToolbarItemEnabled(false);
            compare(toolBar.children[0].enabled, true)
            compare(toolBar.children[1].enabled, false)
            compare(toolBar.children[2].enabled, true)
            compare(toolBar.children[3].enabled, true)
        }

        function test_hud_results() {
            var resultListRepeater = findChild(hud, "resultListRepeater")
            resetToInitialState()

            tryCompare(resultListRepeater, "count", 5)

            compare(resultListRepeater.itemAt(0).children[1].nameText, "Help", "First result name")
            compare(resultListRepeater.itemAt(0).children[1].contextSnippetText, "Get Help", "First result description")

            compare(resultListRepeater.itemAt(1).children[1].nameText, "About", "Second result name")
            compare(resultListRepeater.itemAt(1).children[1].contextSnippetText, "Show About", "Second result description")

            compare(resultListRepeater.itemAt(2).children[1].nameText, "Foo", "Third result name")
            compare(resultListRepeater.itemAt(2).children[1].contextSnippetText, "Show Foo", "Third result description")

            compare(resultListRepeater.itemAt(3).children[1].nameText, "Bar", "Fourth result name")
            compare(resultListRepeater.itemAt(3).children[1].contextSnippetText, "Show Bar", "Fourth result description")

            compare(resultListRepeater.itemAt(4).children[1].nameText, "FooBar", "Fifth result name")
            compare(resultListRepeater.itemAt(4).children[1].contextSnippetText, "Show FooBar", "Fifth result description")
        }

        function test_hud_set_query() {
            var searchBar = findChild(hud, "searchBar")
            resetToInitialState()

            compare(hudClientStub.lastSetQuery, "", "Query should be empty at start")

            searchBar.text = "Hi"
            compare(hudClientStub.lastSetQuery, "Hi", "Query should be updated")

            searchBar.text = "Ho"
            compare(hudClientStub.lastSetQuery, "Ho", "Query should be updated")
        }

        function compareItemAnchoredAtTopOf(itemA, itemB, spacing, text) {
            compare(itemA.y - spacing, itemB.y, text)
        }

        function compareItemAnchoredAtBottomOf(itemA, itemB, spacing, text) {
            compare(itemA.y + itemA.height + spacing, itemB.y + itemB.height, text)
        }

        function compareItemAnchoredUnderItem(itemUnder, itemTop, spacing, text) {
            compare(itemUnder.y - spacing, itemTop.y + itemTop.height, text)
        }

        function compareItemAnchoredOverItem(itemTop, itemUnder, spacing, text) {
            compareItemAnchoredUnderItem(itemUnder, itemTop, spacing, text)
        }

        function test_hud_elements_positioning() {
            var searchBar = findChild(hud, "searchBar")
            var searchBarContainer = findChild(hud, "searchBarAnimator")
            var resultListContainer = findChild(hud, "resultsCardAnimator")
            var toolBarContainer = findChild(hud, "toolBarAnimator")
            var toolBar = findChild(hud, "toolBar")
            var handle = findChild(hud, "handle")
            resetToInitialState()

            compare(toolBar.visible, true, "Toolbar is initially visible")
            compareItemAnchoredAtTopOf(handle, hud, 0, "Handle is anchored at the top")
            compareItemAnchoredAtBottomOf(searchBarContainer, hud, hud.elementsPadding, "SearchBar is anchored at the bottom")
            compareItemAnchoredOverItem(toolBarContainer, searchBarContainer, 2 * hud.elementsPadding, "Toolbar is anchored over the searchBar")
            compareItemAnchoredOverItem(resultListContainer, toolBarContainer, hud.elementsPadding, "ResultsList is anchored over the toolBar")

            mouseClick(searchBar, 0, 0)

            tryCompare(toolBar, "visible", false)
            compareItemAnchoredAtTopOf(handle, hud, 0, "Handle is anchored at the top")
            compareItemAnchoredUnderItem(searchBarContainer, handle, hud.elementsPadding + units.dp(1), "SearchBar is anchored under the handle")
            compareItemAnchoredUnderItem(resultListContainer, searchBarContainer, hud.elementsPadding, "ResultsList is anchored under the searchBar")
        }

        function test_hud_result_suggestion_execution() {
            var resultListRepeater = findChild(hud, "resultListRepeater")
            resetToInitialState()

            mouseClick(resultListRepeater.itemAt(1), 0, 0)
            compare(hudClientStub.lastExecutedCommandRow, 1, "Last executed row was 1")
            compare(hud.shown, false, "Should not be shown after executing")
        }

        function number_of_activated_actions(activatedActionsObject) {
            var activatedActions = 0
            for(var key in activatedActionsObject) {
                ++activatedActions
            }
            return activatedActions
        }

        function test_hud_result_suggestion_parametrized_execution_and_back() {
            var resultListRepeater = findChild(hud, "resultListRepeater")
            var parametrizedActionsPage = findChild(hud, "parametrizedActionsPage")
            var backButton = parametrizedActionsPage.children[1].children[0]
            resetToInitialState()

            compare(parametrizedActionsPage.shown, false, "Parametrized action page should be hidden at start")
            tryCompare(parametrizedActionsPage, "x", hud.width)

            mouseClick(resultListRepeater.itemAt(2), 0, 0)
            compare(hudClientStub.lastExecutedCommandRow, -1, "We executed a param action not a regular one")
            compare(hudClientStub.lastExecutedParametrizedCommandRow, 2, "Last executed row was 2")
            compare(parametrizedActionsPage.shown, true, "Parametrized action page should be shown after executing a parametrized action")
            tryCompare(parametrizedActionsPage, "x", 0)

            var sliderLabel = parametrizedActionsPage.children[0].children[0].children[0].children[1].children[0]
            var slider = parametrizedActionsPage.children[0].children[0].children[0].children[1].children[1]
            compare(sliderLabel.text, "Item1Label")
            compare(slider.minimumValue, 10)
            compare(slider.maximumValue, 80)
            compare(slider.live, true)
            compare(number_of_activated_actions(hudClientStub.activatedActions), 0)

            // Since it's live moving the slider will activate it already
            var slider = parametrizedActionsPage.children[0].children[0].children[0].children[1].children[1]
            mouseClick(slider, units.gu(1), units.gu(1))
            compare(number_of_activated_actions(hudClientStub.activatedActions), 1)
            compare(hudClientStub.activatedActions["costAction"], 10)

            mouseClick(backButton, 0, 0)
            compare(parametrizedActionsPage.shown, false, "Parametrized action page should be hidden after going back")
            compare(hudClientStub.lastParametrizedCommandCommited, false, "Cancelling does not commit")
            tryCompare(parametrizedActionsPage, "x", hud.width)
        }

        function test_hud_result_suggestion_parametrized_execution_and_confirm() {
            var resultListRepeater = findChild(hud, "resultListRepeater")
            var parametrizedActionsPage = findChild(hud, "parametrizedActionsPage")
            var confirmButton = parametrizedActionsPage.children[1].children[2]
            resetToInitialState()

            compare(parametrizedActionsPage.shown, false, "Parametrized action page should be hidden at start")
            tryCompare(parametrizedActionsPage, "x", hud.width)

            mouseClick(resultListRepeater.itemAt(2), 0, 0)
            compare(hudClientStub.lastExecutedCommandRow, -1, "We executed a param action not a regular one")
            compare(hudClientStub.lastExecutedParametrizedCommandRow, 2, "Last executed row was 2")
            compare(parametrizedActionsPage.shown, true, "Parametrized action page should be shown after executing a parametrized action")
            tryCompare(parametrizedActionsPage, "x", 0)
            compare(number_of_activated_actions(hudClientStub.activatedActions), 0)

            mouseClick(confirmButton, 0, 0)
            compare(hud.shown, false, "Should not be shown after executing")
            compare(number_of_activated_actions(hudClientStub.activatedActions), 1)
            compare(hudClientStub.activatedActions["costAction"], 75)
            compare(hudClientStub.lastParametrizedCommandCommited, true, "Confirming does commit")
        }
    }
}
