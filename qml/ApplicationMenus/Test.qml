import QtQuick 2.4
import QtQuick.Window 2.2
import QMenuModel 0.1
import Ubuntu.Components 1.3
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators
import "../Components"

Window {
    id: root
    width:  units.gu(100)
    height:  units.gu(100)
    visible: true

    ListModel {
        id: surfaceIds
    }

    Flickable {
        anchors.fill: parent
        contentHeight: row.height

        Row {
            id: row
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: units.gu(1)

            Repeater {
                model: surfaceIds

                TextArea {
                    id: textArea
                    text: printer.text
                    autoSize: true
                    maximumLineCount: 20

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(1)
                    }
                    height: implicitHeight

                    Indicators.SharedUnityMenuModel {
                        id: sharedAppModel
                        property var menus: ApplicationMenuRegistry.getMenusForSurface(surfaceId)
                        property var menuService: menus.length > 0 ? menus[0] : null

                        busName: menuService ? menuService.service : ""
                        menuObjectPath: menuService && menuService.menuPath ? menuService.menuPath : ""
                        actions: menuService && menuService.actionPath ? { "unity": menuService.actionPath } : {}

                        onBusNameChanged: console.log("BUS NAME", busName)
                        onMenuObjectPathChanged: console.log("MENU PATH", menuObjectPath)
                        onActionsChanged: console.log("ACTIONS", menuService.actionPath)
                    }

                    Indicators.ModelPrinter {
                        id: printer
                        model: sharedAppModel.model
                    }
                }
            }
        }
    }

    Connections {
        target: ApplicationMenuRegistry
        onSurfaceMenuRegistered: {
            console.log("REGISTERED SURFACE!", surfaceId)
            surfaceIds.append({ "surfaceId": surfaceId });
        }

        onAppMenuRegistered: {
            console.log("REGISTERED PROCESS!", processId);
        }
    }
}
