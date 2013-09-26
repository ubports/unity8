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
import Ubuntu.Components 0.1
import "../../../../Dash/Apps"
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    // Fake shell
    QtObject { id: shell; property int height: appPreview.height }

    property var calls: []

    SignalSpy {
        id: sendPreviewSpy
        target: appPreview
        signalName: "sendUserReview"
    }

    property string commentary: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus a mi vitae augue rhoncus lobortis ut rutrum metus. Curabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.";
    QtObject { id: screenshots; property var value: ["fake_image1.png", "fake_image2.png", "fake_image3.png"] }
    QtObject { id: rating; property real value: 0.8 }
    QtObject { id: rated; property int value: 120 }
    QtObject { id: reviews; property int value: 8 }
    QtObject { id: progress; property string value: "source" }
    QtObject { id: comments; property var value: [
            ["Unity User", 4, "08/20/2013", root.commentary],
            ["Unity User", 8, "01/15/2013", root.commentary],
            ["Unity User", 10, "10/02/2013", root.commentary],
        ]
    }

    QtObject {
        id: data
        property string title: "Unity App"
        property string appIcon: "fake_image.png"
        property string description: "This is an Application description"
        property real rating: rating.value
        property int numRatings: reviews.value
        property var execute: root.fake_call
        property var infoMap: {
            "more-screenshots": screenshots,
            "rated": rated,
            "comments": comments
        }
        property var actions: [
            { "id": 123, "displayName": "action1" },
            { "id": 456, "displayName": "action2" },
            { "id": 789, "displayName": "action3" },
        ]
    }

    function fake_call(id, data){
        root.calls[root.calls.length] = id;
    }

    // The component under test
    AppPreview {
        id: appPreview
        anchors.fill: parent

        previewData: data
    }

    UT.UnityTestCase {
        name: "AppPreview"
        when: windowShown

        function cleanup() {
            root.calls = new Array();
            sendPreviewSpy.clear();
            var reviewField = findChild(appPreview, "reviewField");
            reviewField.focus = false;
            reviewField.text = "";
            data.rating = rating.value;
            var appReviews = findChild(appPreview, "appReviews");
            appReviews.visible = false;
            appPreview.keyboardSize = 0;
        }

        function test_actions() {
            var buttons = findChild(appPreview, "gridButtons");
            compare(buttons.count, 3, "Not the proper amount of actions detected.");

            for(var i = 0; i < buttons.count; i++) {
                buttons.currentIndex = i;
                buttons.currentItem.clicked();
            }

            var actions = data.actions;
            for(var i = 0; i < actions.length; i++) {
                compare(root.calls[i], actions[i].id, "Id of action not found.");
            }
        }

        function test_rated() {
            var rated = findChild(appPreview, "ratedLabel");
            compare(rated.text, "(120)", "Rates not equal");
        }

        function test_reviews() {
            var rated = findChild(appPreview, "reviewsLabel");
            compare(rated.text, "8 reviews", "Reviews don't match");
        }

        function test_send_review() {
            var appReviews = findChild(appPreview, "appReviews");
            appReviews.sendReview("review");
            sendPreviewSpy.wait();
        }

        function test_review_focus() {
            skip();
            var appReviews = findChild(appPreview, "appReviews");
            var sendButton = findChild(appReviews, "sendButton");
            var reviewField = findChild(appReviews, "reviewField");

            compare(reviewField.focus, false, "ReviewField shouldn't have focus");
            compare(appReviews.state, "", "State should be empty");

            mouseClick(reviewField, reviewField.width/2, reviewField.height/2);
            compare(reviewField.focus, true, "Review Field should have focus");
            compare(appReviews.state, "editing", "State should be 'editing'");
        }

        function test_comments() {
            var commentsArea = findChild(appPreview, "commentsArea");
            compare(commentsArea.count, 3);
            for(var i = 0; i < 3; i++) {
                var username = commentsArea.itemAt(i).children[0].children[0].text
                var rate = commentsArea.itemAt(i).children[0].children[1].children[0].rating
                var date = commentsArea.itemAt(i).children[0].children[1].children[1].text
                var comment = commentsArea.itemAt(i).children[1].text
                compare(username, comments.value[i][0], "Username don't match");
                compare(rate, comments.value[i][1], "Rating don't match");
                compare(date, comments.value[i][2], "Date don't match");
                compare(comment, comments.value[i][3], "Comment don't match");
            }
        }

        function test_negative_rating() {
            data.rating = -1.0;
            var rated = findChild(appPreview, "reviewsLabel");
            verify(rated.visible == false);
            var commentsArea = findChild(appPreview, "commentsArea");
            verify(commentsArea.visible == false);
            var appReviews = findChild(appPreview, "appReviews");
            verify(appReviews.visible == false);
            var buttons = findChild(appPreview, "gridButtons");
            verify(buttons.visible == true);
        }

        function test_automatic_scroll_on_keyboard_shown() {
            waitForRendering(appPreview);
            var appReviews = findChild(appPreview, "appReviews");
            appReviews.visible = true;

            var leftFlickable = findChild(appPreview, "leftFlickable");
            leftFlickable.contentY = leftFlickable.contentHeight;
            var reviewField = findChild(appReviews, "reviewField");
            appPreview.keyboardSize = 400;
            appReviews.editing(reviewField);
            var newFlickPos = leftFlickable.contentY;
            var keyboardY = shell.height - appPreview.keyboardSize;
            verify(newFlickPos < keyboardY);
        }

    }
}
