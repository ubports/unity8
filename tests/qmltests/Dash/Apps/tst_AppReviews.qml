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
import "../../../../Dash/Apps"
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(50)
    height: units.gu(40)

    property string _username: "Unity User"
    property int _rating: 8
    property string _date: "04/20/2013"
    property string _comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus a mi vitae augue rhoncus lobortis ut rutrum metus. Curabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."

    SignalSpy {
        id: sendReviewSpy
        target: appReviews
        signalName: "sendReview"
    }

    function get_comments() {
        var c1 = new Object();
        c1.username = root._username;
        c1.rate = root._rating;
        c1.date = root._date;
        c1.comment = root._comment;
        var c2 = new Object();
        c2.username = root._username;
        c2.rate = root._rating;
        c2.date = root._date;
        c2.comment = root._comment;
        var c3 = new Object();
        c3.username = root._username;
        c3.rate = root._rating;
        c3.date = root._date;
        c3.comment = root._comment;
        var c4 = new Object();
        c4.username = root._username;
        c4.rate = root._rating;
        c4.date = root._date;
        c4.comment = root._comment;

        return [c1, c2, c3, c4];
    }

    // The component under test
    AppReviews {
        id: appReviews
        anchors.fill: parent

        model: get_comments()
    }

    UT.UnityTestCase {
        name: "AppReviews"
        when: windowShown

        function test_state_nothing() {
            appReviews.state = "";
            var reviewField = findChild(appReviews, "reviewField");
            var sendButton = findChild(appReviews, "sendButton");
            compare(reviewField.width, appReviews.width);
            compare(sendButton.opacity, 0);
        }

        function test_send_review() {
            sendReviewSpy.clear();
            var sendButton = findChild(appReviews, "sendButton");
            mouseClick(sendButton, 1, 1);
            compare(sendReviewSpy.count, 1, "SendReview signal not emitted");
        }

        function test_review_focus() {
            sendReviewSpy.clear();
            var sendButton = findChild(appReviews, "sendButton");
            var reviewField = findChild(appReviews, "reviewField");

            compare(reviewField.focus, false);
            compare(appReviews.state, "");
            mouseClick(reviewField, 1, 1);
            compare(reviewField.focus, true);
            compare(appReviews.state, "editing");
        }

        function test_comments() {
            var commentsArea = findChild(appReviews, "commentsArea");
            compare(commentsArea.count, 4);
            for(var i = 0; i < 4; i++) {
                var username = commentsArea.itemAt(i).children[0].children[0].text
                var rate = commentsArea.itemAt(i).children[0].children[1].children[0].rating
                var date = commentsArea.itemAt(i).children[0].children[1].children[1].text
                var comment = commentsArea.itemAt(i).children[1].text
                compare(username, root._username);
                compare(rate, root._rating);
                compare(date, root._date);
                compare(comment, root._comment);
            }
        }

    }
}
