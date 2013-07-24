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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Utils 0.1
import "../Components"
import "../Components/ListItems"
import "../Applications"
import "Apps"
import "Video"
import "Music"

ScopeView {
    id: root
    objectName: "DashHome"

    onMovementStarted: listView.showHeader()

    ListModel {
        id: categoryListModel
        // specifies page's content categories, type of delegate and model used in each category
        ListElement { category: "Frequent Apps";         component: "Apps/ApplicationsFilterGrid.qml";  modelName: "AppsModel" }
        ListElement { category: "Recent Music";          component: "Music/MusicFilterGrid.qml";        modelName: "MusicModel" }
        ListElement { category: "Videos Popular Online"; component: "Video/VideosFilterGrid.qml";       modelName: "VideosModel" }
        function getCategory(category1) {
            if (category1 === "Frequent Apps") {
                return i18n.tr("Frequent Apps");
            }
            if (category1 === "Recent Music") {
                return i18n.tr("Recent Music");
            }
            if (category1 === "Videos Popular Online") {
                return i18n.tr("Videos Popular Online");
            }
            return ""
        }
    }

    FrequentlyUsedAppsModel { id: appsModel }

    // FIXME this should be handled by the backends by populating the global search model
    property var musicModel: null
    property var videosModel: null

    Repeater {
        id: musicRepeater

        delegate: Item {
            Component.onCompleted: if (index == 1) musicModel = Qt.binding(function() { return model.results; });
        }
    }

    Repeater {
        id: videosRepeater

        delegate: Item {
            Component.onCompleted: if (index == 3) videosModel = Qt.binding(function() { return model.results; });
        }
    }

    Component.onCompleted: {
        var scope = dashContent.scopes.get("mockmusicmaster.scope")
        if (scope) {
            musicRepeater.model = dashContent.scopes.get("mockmusicmaster.scope").categories
        }
        scope = dashContent.scopes.get("mockvideosmaster.scope")
        if (scope) {
            videosRepeater.model = dashContent.scopes.get("mockvideosmaster.scope").categories
        }
    }

    Connections {
        target: dashContent
        onScopeLoaded: switch (scopeId) {
            case "mockmusicmaster.scope":
                musicRepeater.model = dashContent.scopes.get("mockmusicmaster.scope").categories
                break;
            case "mockvideosmaster.scope":
                videosRepeater.model = dashContent.scopes.get("mockvideosmaster.scope").categories
                break;
        }
    }

    property var categoryModels: {"AppsModel": appsModel,
                                  "MusicModel": musicModel,
                                  "VideosModel": videosModel,
                                 }

    ScopeListView {
        id: listView
        anchors.fill: parent
        model: categoryListModel

        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        delegate: Base {
            id: container
            highlightWhenPressed: false
            width: listView.width

            Loader {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                source: component
                onLoaded: {
                    item.model = Qt.binding(function() { return categoryModels[modelName]; });

                    //FIXME: workaround for lack of previews for videos in Home scope.
                    //Need to connect to the clicked() signal here and act upon it here instead.
                    if (modelName === "VideosModel") {
                        function playVideo(index, data) {
                            if (data.fileUri) {
                                shell.activateApplication('/usr/share/applications/mediaplayer-app.desktop', "/usr/share/demo-assets/videos/" + data.fileUri);
                            }
                        }

                        item.clicked.connect(playVideo);
                    } else if (modelName === "AppsModel") {
                        function activateApplication(index, data) {
                            shell.activateApplication(data);
                        }

                        item.objectName = "dashHomeApplicationsGrid";
                        item.clicked.connect(activateApplication);
                    }
                }
            }
        }

        sectionProperty: "category"
        sectionDelegate: Header {
            width: listView.width
            text: listView.model.getCategory(section)
        }
        pageHeader: PageHeader {
            width: listView.width
            text: i18n.tr("Home")
        }
    }
}
