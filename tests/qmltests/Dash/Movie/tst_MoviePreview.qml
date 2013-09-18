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
import "../../../../Dash/Movie"
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var calls: []
    property int counter: 0

    function get_actions_data() {
        return [
            { id: 123, displayName: "Play", iconHint: "image://theme/search" },
            { id: 456, displayName: "Buy", iconHint: "image://theme/search" },
            { id: 789, displayName: "Delete", iconHint: "image//theme/search" }
        ]
    }

    function fake_callback(id, data){
        root.calls[root.calls.length] = id;
    }

    // The component under test
    MoviePreview {
        id: moviePreview
        anchors.fill: parent

        previewData: QtObject {
            property string rendererName: "preview-movie"
            property string title: "Unity Movie"
            property string subtitle: "Subtitle"
            property string description: "This is the description"
            property string image: "image://theme/syncing"
            property var actions: get_actions_data()
            property string year: "2013"
            property real rating: 0.3
            property int numRatings: 1
            property var execute: fake_callback
        }
    }

    UT.UnityTestCase {
        name: "MoviePreviewTest"
        when: windowShown

        function init() {
            root.calls = new Array();
        }

        function test_numofbuttons() {
            var buttons = findChild(moviePreview, "gridButtons");
            compare(buttons.count, 3);

            for(var i = 0; i < buttons.count; i++) {
                buttons.currentIndex = i;
                buttons.currentItem.clicked();
            }

            var actions = get_actions_data();
            for(var i = 0; i < actions.length; i++) {
                compare(root.calls[i], actions[i].id);
            }
        }
    }
}
