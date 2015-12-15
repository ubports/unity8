/*
 * Copyright 2014,2015 Canonical Ltd.
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

    Component.onCompleted: {
        for (var i = 0; i < 500; ++i) {
            widgetData500.reviews.push({ author: "Some dude", review: "Very cool app" + i });
        }
        factory.widgetData = widgetData500;
    }

    UT.UnityTestCase {
        name: "PreviewRatingDisplayTest"
        when: windowShown

        function test_creation_speed() {
            factory.parentFlickable = null;
            factory.widgetData = reviewsEmpty;
            waitForRendering(root);

            var start = new Date().getTime();
            factory.widgetData = widgetData500;
            waitForRendering(root);
            var end = new Date().getTime();
            var time500 = end - start;

            factory.widgetData = reviewsEmpty;
            waitForRendering(root);

            factory.parentFlickable = root;
            start = new Date().getTime();
            factory.widgetData = widgetData500;
            waitForRendering(root);
            end = new Date().getTime();
            var timeRanges500 = end - start;

            // Measurements show it's usually like 20 times faster
            // but we set the range at 8 times fast to make sure it's not an unstable test
            verify(timeRanges500 * 8 < time500);
        }

        function test_check_indexes() {
            // Check that item 499 isn't there on startup but if we scroll down
            // it will be there
            var reviewItem499 = findChild(factory, "reviewItem499");
            verify(reviewItem499 === null);

            flickToYEnd(root);

            var reviewItem499 = findChild(factory, "reviewItem499");
            verify(reviewItem499 !== null);
        }
    }
}
