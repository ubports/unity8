import QtQuick 2.4
import Unity.Application 0.1

QtObject {
    id: root

    // input
    property int itemIndex: 0
    property int sceneWidth: 0
    property int sideStageWidth: 0
    property int sideStageX: sceneWidth

    property int stage: ApplicationInfoInterface.MainStage
    property var thisDelegate: null
    property var mainStageDelegate: null
    property var sideStageDelegate: null

    // output
    readonly property int itemZ: stage == ApplicationInfoInterface.MainStage ? 0 :
                                 stage == ApplicationInfoInterface.SideStage ? 2 :
                                 itemIndex + 2

    readonly property int itemX: mainStageDelegate == thisDelegate ? 0 :
                                 sideStageDelegate == thisDelegate ? sideStageX :
                                 sceneWidth

    readonly property int itemWidth: stage == ApplicationInfoInterface.MainStage ?
                                         sideStageDelegate != null ? sideStageX : sceneWidth :
                                     stage == ApplicationInfoInterface.SideStage ? sideStageWidth : sceneWidth
}
