/*
 * Copyright 2014-2016 Canonical Ltd.
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
import QtTest 1.0
import Ubuntu.Components 1.3
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Flickable {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    contentHeight: factory.implicitHeight

    property var reviewsEmpty: {
        "reviews": [ ]
    }

    Item {
        id: widgetData500
        property var reviews: []
    }

    PreviewWidgetFactory {
        id: factory
        anchors.fill: parent
        widgetType: "reviews"
        parentFlickable: root
    }

    property int createdDelegates: 0

    Component.onCompleted: {
        for (var i = 0; i < 500; ++i) {
            widgetData500.reviews.push({ author: "Some dude", review: "Very cool app" + i });
        }
        factory.widgetData = widgetData500;
    }

    Component {
        id: countingPreviewRatingSingleDisplayComponent
        PreviewRatingSingleDisplay {
            objectName: "reviewItem" + index

            anchors { left: parent.left; right: parent.right; }

            rating: modelData["rating"] || -1
            author: modelData["author"] || ""
            review: modelData["review"] || ""
            Component.onCompleted: root.createdDelegates++;
        }
    }

    UT.UnityTestCase {
        name: "PreviewRatingDisplayCreationRangesTest"
        when: windowShown

        function initTestCase() {
            var lists = findChildsByType(factory, "QQuickListView");
            compare(lists.length, 1)
            lists[0].delegate = countingPreviewRatingSingleDisplayComponent;
        }

        function test_check_delegate_creation_range() {
            // Clear the reviews
            factory.widgetData = reviewsEmpty;
            waitForRendering(root);

            // Unset parentFlickable this disables the creation range code
            factory.parentFlickable = null;
            root.createdDelegates = 0;

            // Set the 500 reviews data
            factory.widgetData = widgetData500;
            waitForRendering(root);

            // Check we have created 500 delegates
            compare(root.createdDelegates, 500);

            // Check review 499 has been created
            var reviewItem499 = findChild(factory, "reviewItem499");
            verify(reviewItem499 !== null);

            // Clear the reviews
            factory.widgetData = reviewsEmpty;
            waitForRendering(root);

            // set parentFlickable to enable the creation ranges code
            factory.parentFlickable = root;
            root.createdDelegates = 0;

            // Set the 500 reviews data
            factory.widgetData = widgetData500;
            waitForRendering(root);

            // Check we have only created a few delegates
            // For some reason xenial and yaketti we get 16 and on vivid 15 so
            // settle for <= 20
            expectFailContinue("", "Should not create more than 20 delegates when using ranges");
            tryCompareFunction(function() { return root.createdDelegates > 20 }, true);

            // Check that item 499 isn't there on startup but if we scroll down
            // it will be there
            var reviewItem499 = findChild(factory, "reviewItem499");
            verify(reviewItem499 === null);

            flickToYEnd(root);

            var reviewItem499 = findChild(factory, "reviewItem499");
            verify(reviewItem499 !== null);

            // Check we have created 500 delegates
            compare(root.createdDelegates, 500);
        }
    }
}
