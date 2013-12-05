import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../../Dash"


Rectangle {
    width: units.gu(40)
    height: units.gu(72)
    color: "lightgrey"

    CardHeader {
        id: cardHeader
        anchors { left: parent.left; right: parent.right }
    }

    Rectangle {
        anchors.fill: cardHeader
        color: "lightblue"
        opacity: 0.5
    }

    TestCase {
        id: testCase

        when: windowShown

        // Find an object with the given name in the children tree of "obj"
        function findChild(obj,objectName) {
            var childs = new Array(0);
            childs.push(obj)
            while (childs.length > 0) {
                if (childs[0].objectName == objectName) {
                    return childs[0]
                }
                for (var i in childs[0].children) {
                    childs.push(childs[0].children[i])
                }
                childs.splice(0, 1);
            }
            return null;
        }

        property Item avatar: findChild(cardHeader, "avatarShape")
        property Item titleLabel: findChild(cardHeader, "titleLabel")
        property Item subtitleLabel: findChild(cardHeader, "subtitleLabel")
        property Item prices: findChild(cardHeader, "prices")
        property Item oldPriceLabel: findChild(cardHeader, "oldPriceLabel")

        function initTestCase() {
            verify(testCase.avatar !== undefined, "Couldn't find avatar object.");
            verify(testCase.titleLabel !== undefined, "Couldn't find titleLabel object.");
            verify(testCase.subtitleLabel !== undefined, "Couldn't find subtitleLabel object.");
            verify(testCase.prices !== undefined, "Couldn't find prices object.");
            verify(testCase.oldPriceLabel !== undefined, "Couldn't find oldPriceLabel object.");
        }

        function cleanup() {
            cardHeader.mascot = "";
            cardHeader.title = "";
            cardHeader.subtitle = "";
            cardHeader.price = "";
            cardHeader.oldPrice = "";
            cardHeader.altPrice = "";
        }

        function test_avatar_data() {
            return [
                        { tag: "Empty", source: "", visible: false },
                        { tag: "Invalid", source: "bad_path", visible: false },
                        { tag: "Valid", source: "artwork/avatar.png", visible: true },
            ]
        }

        function test_avatar(data) {
            cardHeader.mascot = data.source;
            tryCompare(testCase.avatar, "visible", data.visible);
        }

        function test_labels_data() {
            return [
                        { tag: "Empty", visible: false },
                        { tag: "Title only", title: "Foo", visible: true },
                        { tag: "Subtitle only", subtitle: "Bar", visible: false },
                        { tag: "Both", title: "Foo", subtitle: "Bar", visible: true }
            ]
        }

        function test_labels(data) {
            cardHeader.title = data.title !== undefined ? data.title : "";
            cardHeader.subtitle = data.subtitle !== undefined ? data.subtitle : "";
            tryCompare(cardHeader, "visible", data.visible);
            if (data.maxLineCount != undefined) {
                compare(testCase.titleLabel.maximumLineCount, data.maxLineCount, "titleLabel maximumLineCount should be %1".arg(data.maxLineCount));
            }
        }

        function test_prices_data() {
            return [
                        { tag: "Main", main: "$1.25", visible: true },
                        { tag: "Alt", alt: "€1.00", visible: false },
                        { tag: "Old", old: "€2.00", visible: false },
                        { tag: "Main and Alt", main: "$1.25", alt: "€1.00", visible: true },
                        { tag: "Main and Old", main: "$1.25", old: "$2.00", visible: true, oldAlign: Text.AlignRight },
                        { tag: "Alt and Old", alt: "€1.00", old: "$2.00", visible: false },
                        { tag: "All", main: "$1.25", alt: "€1.00", old: "$2.00", visible: true, oldAlign: Text.AlignHCenter }
            ]
        }

        function test_prices(data) {
            cardHeader.price = data.main !== undefined ? data.main : "";
            cardHeader.oldPrice = data.old !== undefined ? data.old : "";
            cardHeader.altPrice = data.alt !== undefined ? data.alt : "";
            tryCompare(cardHeader, "visible", data.visible);
            if (data.oldAlign !== undefined) {
                compare(testCase.oldPriceLabel.horizontalAlignment, data.oldAlign, "Old price label is aligned wrong.")
            }
        }
    }
}
