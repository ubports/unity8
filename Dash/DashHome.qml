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
import ListViewWithPageHeader 0.1
import "../Components"
import "../Components/ListItems"
import "../Applications"
import "Apps"
import "Video"
import "Music"
import "People"

LensView {
    id: root

    onMovementStarted: listView.showHeader()

    ListModel {
        id: categoryListModel
        // specifies page's content categories, type of delegate and model used in each category
        ListElement { category: "Frequent Apps";         component: "AppsGrid";       modelName: "AppsModel" }
        ListElement { category: "Favourite People";      component: "PeopleCarousel"; modelName: "FavouriteModel" }
        ListElement { category: "People Recently in Touch"; component: "PeopleGrid";  modelName: "RecentModel" }
        ListElement { category: "Recent Music";          component: "MusicGrid";      modelName: "MusicModel" }
        ListElement { category: "Videos Popular Online"; component: "VideosGrid";     modelName: "VideosModel" }
        function getCategory(category1) {
            if (category1 === "Frequent Apps") {
                return i18n.tr("Frequent Apps");
            }
            if (category1 === "Favourite People") {
                return i18n.tr("Favourite People");
            }
            if (category1 === "People Recently in Touch") {
                return i18n.tr("People Recently in Touch");
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
    SortFilterProxyModel {
        id: favouritesFilter
        dynamicSortFilter: true
        filterRole: 2
        filterRegExp: /^0$/
    }

    SortFilterProxyModel {
        id: recentFilter
        dynamicSortFilter: true
        filterRole: 2
        filterRegExp: /^2$/
    }

    SortFilterProxyModel {
        id: musicFilter
        dynamicSortFilter: true
        filterRole: 2
        filterRegExp: /^1$/
    }

    SortFilterProxyModel {
        id: videosFilter
        dynamicSortFilter: true
        filterRole: 2
        filterRegExp: /^3$/
    }

    Component.onCompleted: {
        var lens = dashContent.lenses.get("people.lens")
        if (lens) {
            favouritesFilter.model = dashContent.lenses.get("people.lens").results
            recentFilter.model = dashContent.lenses.get("people.lens").results
        }
        lens = dashContent.lenses.get("mockmusic.lens")
        if (lens) {
            musicFilter.model = dashContent.lenses.get("mockmusic.lens").results
        }
        lens = dashContent.lenses.get("mockvideos.lens")
        if (lens) {
            videosFilter.model = dashContent.lenses.get("mockvideos.lens").results
        }
    }

    Connections {
        target: dashContent
        onLensLoaded: switch (lensId) {
            case "people.lens":
                favouritesFilter.model = dashContent.lenses.get("people.lens").results
                recentFilter.model = dashContent.lenses.get("people.lens").results
                break;
            case "mockmusic.lens":
                musicFilter.model = dashContent.lenses.get("mockmusic.lens").results
                break;
            case "mockvideos.lens":
                videosFilter.model = dashContent.lenses.get("mockvideos.lens").results
                break;
        }
    }

    property var categoryModels: {"AppsModel": appsModel,
                                  "FavouriteModel": favouritesFilter,
                                  "RecentModel": recentFilter,
                                  "MusicModel": musicFilter,
                                  "VideosModel": videosFilter,
                                 }

    /* Workaround for bug: https://bugreports.qt-project.org/browse/QTBUG-28403
       When using Loader to load external QML file in the list deelgate, the ListView has
       a bug where it can position the delegate content to overlap the section header
       of the ListView - a workaround is to use sourceComponent of Loader instead */
    Component {
        id: applicationsFilterGrid
        ApplicationsFilterGrid {
            objectName: "dashHomeApplicationsGrid"
            onClicked: shell.activateApplication(data);
        }
    }

    Component { id: peopleCarousel; PeopleCarousel {}   }
    Component { id: peopleGrid;     PeopleFilterGrid {} }
    Component { id: musicGrid;      MusicFilterGrid {}  }
    Component { id: videosGrid;     VideosFilterGrid {} }
    property var componentModels: {
                "AppsGrid": applicationsFilterGrid,
                "PeopleCarousel": peopleCarousel,
                "PeopleGrid": peopleGrid,
                "MusicGrid": musicGrid,
                "VideosGrid": videosGrid,
    }

    ListViewWithPageHeader {
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
                sourceComponent: componentModels[component]
                onLoaded: {
                    item.model = categoryModels[modelName]

                    //FIXME: workaround for lack of previews for videos in Home lens.
                    //Need to connect to the clicked() signal here and act upon it here instead.
                    if (component === "VideosGrid") {
                        function playVideo(index, data) {
                            if (data.fileUri) {
                                shell.activateApplication('/usr/share/applications/mediaplayer-app.desktop', "/usr/share/demo-assets/videos/" + data.fileUri);
                            }
                        }

                        item.clicked.connect(playVideo);
                    }
                }
                asynchronous: true
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
