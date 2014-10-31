import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1

UbuntuShape {
    id: optionToggle

    property bool expanded
    property var model
    property int startIndex
    readonly property double itemHeight: units.gu(5)

    signal triggered(string id)

    Behavior on height {
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.SnapDuration
        }
    }

    color: Theme.palette.normal.base
    borderSource: "none"
    height: expanded ? (optionToggleRepeater.count - startIndex) * itemHeight : itemHeight
    width: parent.width
    radius: "medium"
    clip: true

    Column {
        id: optionToggleContent
        width: parent.width

        Repeater {
            id: optionToggleRepeater
            model: optionToggle.model

            delegate: Loader {
                asynchronous: true
                visible: status === Loader.Ready
                property string actionLabel: label
                property string actionId: id
                readonly property var splitLabel: actionLabel.match(/(^([-a-z0-9]+):)?(.*)$/)

                Component {
                    id: optionToggleEntry

                    MouseArea {
                        width: optionToggleContent.width
                        height: optionToggle.itemHeight

                        onClicked: {
                            if (index === startIndex) {
                                optionToggle.expanded = optionToggle.expanded ? false : true
                            } else {
                                optionToggle.triggered(actionId)
                            }
                        }

                        ListItem.ThinDivider {
                            visible: index > startIndex
                        }

                        Icon {
                            id: delegateIcon
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(2)
                                verticalCenter: parent.verticalCenter
                            }
                            visible: index !== startIndex
                            width: units.gu(2)
                            height: width
                            name: splitLabel[2] !== undefined ? splitLabel[2] : ""
                        }

                        Label {
                            id: delegateLabel
                            anchors {
                                left: delegateIcon.visible ? delegateIcon.right : parent.left
                                leftMargin: delegateIcon.visible ? units.gu(1) : units.gu(2)
                                right: parent.right
                                rightMargin: units.gu(2)
                                verticalCenter: delegateIcon.visible ? delegateIcon.verticalCenter : parent.verticalCenter
                            }

                            width: parent.width
                            text: splitLabel[3]
                            color:"#5d5d5d"
                            fontSize: "small"
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }

                        Icon {
                            anchors {
                                right: parent.right
                                rightMargin: units.gu(2)
                                verticalCenter: delegateIcon.verticalCenter
                            }

                            visible: index === startIndex
                            name: optionToggle.height === optionToggle.itemHeight ? "down" : "up"
                            width: units.gu(2)
                            height: width
                        }
                    }
                }
                sourceComponent: (index >= startIndex) ? optionToggleEntry : undefined
            }
        }
    }
}
