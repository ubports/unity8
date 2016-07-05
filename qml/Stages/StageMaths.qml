import QtQuick 2.4
import Unity.Application 0.1

QtObject {
    id: root

    // input
    property int itemIndex: 0
    property int sceneWidth: 0
    property int sideStageWidth: units.gu(40)

    property int stage: ApplicationInfoInterface.MainStage
    property var thisDelegate: null
    property var mainStageDelegate: null
    property var sideStageDelegate: null

    // output
    readonly property int itemX: stage == ApplicationInfoInterface.MainStage ? 0 :
                                 stage == ApplicationInfoInterface.SideStage ? sceneWidth - sideStageWidth :
                                 sceneWidth

    readonly property int itemWidth: stage == ApplicationInfoInterface.MainStage ? sceneWidth - sideStageWidth :
                                     stage == ApplicationInfoInterface.SideStage ? sideStageWidth : sceneWidth
}
