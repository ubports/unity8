import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Launcher 0.1
import Utils 0.1
import "../Components"

FocusScope {
    id: root

    property int panelWidth: 0
    readonly property bool moving: listLoader.item && listLoader.item.moving

    signal applicationSelected(string appId)

    Rectangle {
        anchors.fill: parent
        color: "#BF000000"

        AppDrawerModel {
            id: appDrawerModel
        }

        AppDrawerProxyModel {
            id: sortProxyModel
            source: appDrawerModel
            filterString: searchField.text
        }

        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.leftMargin: root.panelWidth

            TextField {
                id: searchField
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                placeholderText: i18n.tr("Search...")
                focus: true
            }

            Item {
                id: sectionsContainer
                anchors { left: parent.left; top: searchField.bottom; right: parent.right; }
                height: sections.height
                clip: true
                z: 2

                Sections {
                    id: sections
                    width: parent.width
                    actions: [
                        Action {
                            text: "A-Z"
                        },
                        Action {
                            text: "Most used"
                        }
                    ]

                    Rectangle {
                        anchors.bottom: parent.bottom
                        height: units.dp(1)
                        color: 'gray'
                        width: contentContainer.width
                    }
                }
            }

            Loader {
                id: listLoader
                anchors { left: parent.left; top: sectionsContainer.bottom; right: parent.right; bottom: parent.bottom; leftMargin: units.gu(1); rightMargin: units.gu(1) }
                sourceComponent: sections.selectedIndex == 0 ? aToZComponent : mostUsedComponent
            }

            Component {
                id: mostUsedComponent
                ListView {
                    anchors.fill: parent
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                    spacing: units.gu(1)
                    clip: true

                    header: MoreAppsHeader {
                        width: parent.width
                        height: units.gu(6)
                    }

                    model: AppDrawerProxyModel {
                        source: sortProxyModel
                        group: AppDrawerProxyModel.GroupByAll
                    }

                    delegate: UbuntuShape {
                        width: parent.width
                        color: "#20ffffff"
                        aspect: UbuntuShape.Flat
                        // NOTE: Cannot use gridView.rows here as it would evaluate to 0 at first and only update later,
                        // which messes up the ListView.
                        height: (Math.ceil(mostUsedGridView.model.count / mostUsedGridView.columns) * mostUsedGridView.delegateHeight) + units.gu(2)

                        DrawerGridView {
                            id: mostUsedGridView
                            anchors.fill: parent
                            topMargin: units.gu(1)
                            bottomMargin: units.gu(1)
                            clip: true

                            model: sortProxyModel


                            delegateWidth: units.gu(8)
                            delegateHeight: units.gu(10)
                            delegate: drawerDelegateComponent
                        }
                    }
                }
            }

            Component {
                id: aToZComponent
                ListView {
                    anchors.fill: parent
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                    spacing: units.gu(1)
                    clip: true

                    header: MoreAppsHeader {
                        width: parent.width
                        height: units.gu(6)
                    }

                    model: AppDrawerProxyModel {
                        source: sortProxyModel
                        group: AppDrawerProxyModel.GroupByAToZ
                    }

                    delegate: UbuntuShape {
                        width: parent.width
                        color: "#20ffffff"
                        aspect: UbuntuShape.Flat

                        // NOTE: Cannot use gridView.rows here as it would evaluate to 0 at first and only update later,
                        // which messes up the ListView.
                        height: (Math.ceil(gridView.model.count / gridView.columns) * gridView.delegateHeight) +
                                categoryNameLabel.implicitHeight + units.gu(2)

                        Label {
                            id: categoryNameLabel
                            anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                            text: model.letter
                        }

                        DrawerGridView {
                            id: gridView
                            anchors { left: parent.left; top: categoryNameLabel.bottom; right: parent.right; topMargin: units.gu(1) }
                            height: rows * delegateHeight

                            interactive: false

                            model: AppDrawerProxyModel {
                                id: categoryModel
                                source: sortProxyModel
                                filterLetter: model.letter
                            }
                            delegateWidth: units.gu(8)
                            delegateHeight: units.gu(10)
                            delegate: drawerDelegateComponent
                        }
                    }
                }
            }
        }

        Component {
            id: drawerDelegateComponent
            AbstractButton {
                width: GridView.view.cellWidth
                height: units.gu(10)

                onClicked: root.applicationSelected(model.appId)

                Column {
                    width: units.gu(8)
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: childrenRect.height
                    spacing: units.gu(1)

                    UbuntuShape {
                        id: appIcon
                        width: units.gu(6)
                        height: 7.5 / 8 * width
                        anchors.horizontalCenter: parent.horizontalCenter
                        backgroundMode: UbuntuShape.SolidColor
                        backgroundColor: UbuntuColors.lightGrey
                        radius: "medium"
                        borderSource: 'undefined'
                        source: Image {
                            id: sourceImage
                            sourceSize.width: appIcon.width
                            source: model.icon
                        }
                        sourceFillMode: UbuntuShape.PreserveAspectCrop
                    }

                    Label {
                        text: model.name
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        fontSize: "small"
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
