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
    width: units.gu(60)
    height: units.gu(80)

    property var calls

    SignalSpy {
        id: sendPreviewSpy
        target: appPreview
        signalName: "sendUserReview"
    }

    function get_actions() {
        var a1 = new Object();
        a1.id = 123;
        a1.displayName = "action1";
        var a2 = new Object();
        a2.id = 456;
        a2.displayName = "action2";
        var a3 = new Object();
        a3.id = 789;
        a3.displayName = "action3";

        return [a1, a2, a3];
    }

    function get_comments() {
        var commentary = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus a mi vitae augue rhoncus lobortis ut rutrum metus. Curabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.";
        var c1 = new Object();
        c1.username = "Unity User";
        c1.rate = 4;
        c1.date = "08/20/2013";
        c1.comment = commentary;
        var c2 = new Object();
        c2.username = "Unity User";
        c2.rate = 8;
        c2.date = "01/15/2013";
        c2.comment = commentary;
        var c3 = new Object();
        c3.username = "Unity User";
        c3.rate = 10;
        c3.date = "10/02/2013";
        c3.comment = commentary;

        return [c1, c2, c3];
    }

    function get_infohints() {
        var i1 = ["fake_image1.png", "fake_image2.png", "fake_image3.png"];
        var i2 = 8;
        var i3 = 120;
        var i4 = 8;
        var i5 = get_comments();

        return [i1, i2, i3, i4, i5];
    }

    function get_data() {
        var objData = new Object();
        objData.title = "Unity App";
        objData.image = "fake_image.png";
        objData.infoHints = get_infohints();
        objData.description = "This is an Application description";
        objData.actions = get_actions();
        objData.execute = prueba;

        return objData;
    }

    function prueba(id, data){
        root.calls[root.calls.length] = id;
    }

    // The component under test
    AppPreview {
        id: appPreview
        anchors.fill: parent

        previewData: get_data()
    }

    UT.UnityTestCase {
        name: "AppReviews"
        when: windowShown

        function test_actions() {
            root.calls = new Array();
            var buttons = findChild(appPreview, "gridButtons");
            compare(buttons.count, 3);

            for(var i = 0; i < buttons.count; i++) {
                buttons.currentIndex = i;
                buttons.currentItem.clicked();
            }

            var actions = get_actions();
            for(var i = 0; i < actions.length; i++) {
                compare(root.calls[i], actions[i].id);
            }
        }
    }
}
