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

import QtQuick 2.4
import QtTest 1.0
import Dash 0.1

Rectangle {
    width: 300
    height: 542
    color: "lightblue"

    ListModel {
        id: model

        function insertItem(index, size, type) {
            insert(index, { size: size, type: type });
        }

        function removeItems(index, count) {
            remove(index, count);
        }

        function moveItems(indexFrom, indexTo, count) {
            move(indexFrom, indexTo, count);
        }

        ListElement { type: "Agressive"; size: 150 }
        ListElement { type: "Regular"; size: 200 }
        ListElement { type: "Mild"; size: 350 }
        ListElement { type: "Bold"; size: 350 }
        ListElement { type: "Bold"; size: 350 }
        ListElement { type: "Lazy"; size: 350 }
    }

    ListViewWithPageHeader {
        id: listView
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: model
        delegate: Rectangle {
            property bool timerDone: false
            width: parent.width - 20
            x: 10
            color: index % 2 == 0 ? "red" : "blue"
            height: size
            Text {
                text: index
            }
        }

        pageHeader: Rectangle {
            color: "transparent"
            width: parent.width
            height: 50
            implicitHeight: 50
            Text {
                anchors.fill: parent
                text: "APPS"
                font.pixelSize: 40
            }
        }

        sectionProperty: "type"

        property int sectionHeaderHeight: 40
        sectionDelegate: Component {
            id: sectionHeaderComponent
            Rectangle {
                color: "green"
                height: listView.sectionHeaderHeight
                Text { text: section; font.pixelSize: 34 }
                anchors { left: parent.left; right: parent.right }
            }
        }
    }

    Component {
        id: otherSectionHeaderComponent
        Rectangle {
            color: "green"
            height: 50
            Text { text: section; font.pixelSize: 34 }
            anchors { left: parent.left; right: parent.right }
        }
    }

    SignalSpy {
        id: stickyHeaderHeigthSpy
        target: listView
        signalName: "stickyHeaderHeightChanged"
    }

    TestCase {
        name: "ListViewWithPageHeaderTest"
        when: windowShown

        function test_stickyHeaderHeightNewHeader() {
            stickyHeaderHeigthSpy.clear();
            compare(listView.stickyHeaderHeight, 40);

            listView.sectionDelegate = otherSectionHeaderComponent;
            compare(listView.stickyHeaderHeight, 50);
            compare(stickyHeaderHeigthSpy.count, 1);

            listView.sectionDelegate = sectionHeaderComponent;
            compare(listView.stickyHeaderHeight, 40);
            compare(stickyHeaderHeigthSpy.count, 2);
        }

        function test_stickyHeaderHeightGrowingHeader() {
            stickyHeaderHeigthSpy.clear();

            compare(listView.stickyHeaderHeight, 40);

            listView.sectionHeaderHeight = 60;
            compare(listView.stickyHeaderHeight, 60);
            compare(stickyHeaderHeigthSpy.count, 1);

            // Restore height for other tests
            listView.sectionHeaderHeight = 40;
        }
    }
}
