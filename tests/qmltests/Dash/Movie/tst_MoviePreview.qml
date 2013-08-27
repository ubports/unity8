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

    property var calls

    function get_actions() {
        var a1 = new Object();
        a1.id = 123;
        a1.displayName = "Play";
        a1.iconHint = "image://gicon/gtk-yes";
        var a2 = new Object();
        a2.id = 456;
        a2.displayName = "Buy";
        a2.iconHint = "image://gicon/gtk-yes";
        var a3 = new Object();
        a3.id = 789;
        a3.displayName = "Delete";
        a3.iconHint = "image://gicon/gtk-yes";

        return [a1, a2, a3];
    }

    function get_data() {
        var objData = new Object();
        objData.rendererName = "preview-movie";
        objData.title = "Unity Movie";
        objData.subtitle = "Subtitle";
        objData.description = "This is the description";
        objData.image = "image://gicon/gtk-stop";
        objData.actions = get_actions();
        objData.year = "2013"
        objData.rating = 3
        objData.numRatings = 1
        objData.execute = prueba;

        return objData;
    }

    function prueba(id, data){
        root.calls[root.calls.length] = id;
    }

    // The component under test
    MoviePreview {
        id: moviePreview
        anchors.fill: parent

        previewData: get_data()
    }

    UT.UnityTestCase {
        name: "MoviePreviewTest"
        when: windowShown

        function test_actions() {
            root.calls = new Array();
            var buttons = findChild(moviePreview, "gridButtons");
            wait(10000);
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
