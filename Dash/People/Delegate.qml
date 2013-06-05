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
import "../../Components"
import "../../Components/Time.js" as Time

Item {
    id: peopleView

    property var dataModel

    property int __spacing: units.gu(1)

    /* Select what is shown in the subtitle
       data: phone number or email address
       status: social media presence status
    */
    property string subtitleType: "data"
    height: subtitleType == "data" && detailsLabel.lineCount < 2 ? units.gu(10) : units.gu(11.5)

    Row {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: units.gu(2)
            rightMargin: units.gu(4)
            top: parent.top
            topMargin: units.gu(2)
        }
        spacing: __spacing

        UbuntuShape {
            id: avatar
            anchors { top: parent.top }
            width: units.gu(6)
            height: units.gu(6)
            image: Image {
                width: units.gu(6)
                source: peopleView.dataModel.avatar
                sourceSize { width: avatar.width; height: avatar.height }
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: false
            }
        }

        Grid {
            spacing: units.gu(0.5)
            width: parent.width - x
            columns: 2

            Item {
                height: units.gu(2)
                width: units.gu(2)

                Image {
                    id: statusImage
                    source: peopleView.dataModel.statusIcon
                    width: units.gu(1.5)
                    height: units.gu(1.5)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Label {
                id: nameLabel
                elide: Text.ElideRight
                text: peopleView.dataModel.name
                color: "#f3f3e7"
                style: Text.Raised
                styleColor: "black"
                font.weight: Font.DemiBold;
                opacity: 0.9;
            }

            Image {
                source: switch(peopleView.subtitleType) {
                        case "data":
                            return peopleView.dataModel.remoteSourceIcon;
                        case "status":
                            return peopleView.dataModel.recent ? peopleView.dataModel.recentIcon : "";
                        }

                width: units.gu(1.5)
                height: units.gu(1.5)
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Label {
                id: detailsLabel
                width: parent.width - x
                elide: Text.ElideRight
                text: switch (peopleView.subtitleType) {
                    case "data":
                        if (peopleView.dataModel.phones && peopleView.dataModel.phones.count > 0) {
                            return peopleView.dataModel.phones.get(0).number;
                        } else if (peopleView.dataModel.emails && peopleView.dataModel.emails.count > 0) {
                            return peopleView.dataModel.emails.get(0).address;
                        }
                        return "";
                    case "status":
                        return peopleView.dataModel.status;
                     }
                color: "#f3f3e7"
                style: Text.Raised
                styleColor: "black"
                opacity: 0.7;
                fontSize: "small";
                wrapMode: Text.WordWrap;
                maximumLineCount: 2;
            }

            Item {
                height: units.gu(2)
                width: units.gu(1.5)

                // Placeholder
            }

            Label {
                width: parent.width - x
                elide: Text.ElideRight
                text: switch (peopleView.subtitleType) {
                      case "data":
                          if (peopleView.dataModel.phones && peopleView.dataModel.phones.count > 0) {
                              return peopleView.dataModel.phones.get(0).type;
                          } else if (peopleView.dataModel.emails && peopleView.dataModel.emails.count > 0) {
                              return peopleView.dataModel.emails.get(0).type;
                          }
                          return "";
                      case "status":
                          if (peopleView.dataModel.recent) {
                              var time = Time.readableFromNow(peopleView.dataModel.recentTime);
                              return time ? time : peopleView.dataModel.recentTime;
                          } else {
                              return peopleView.dataModel.status
                          }
                      }
                color: "#8f8f88"
                style: Text.Raised
                styleColor: "black"
                opacity: 0.7;
                fontSize: "x-small";
            }
        }
    }
}
