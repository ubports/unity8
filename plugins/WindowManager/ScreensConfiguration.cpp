/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "ScreensConfiguration.h"
#include "Screen.h"
#include "Workspace.h"
#include "WorkspaceManager.h"

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QStandardPaths>

namespace
{
QJsonArray jsonScreens;
}

ScreensConfiguration::ScreensConfiguration()
{
    const QString dbPath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/");
    QFile f(dbPath + "workspaces");

    if (f.open(QIODevice::ReadOnly)) {
        QByteArray saveData = f.readAll();
        QJsonDocument loadDoc(QJsonDocument::fromJson(saveData));
        QJsonObject json(loadDoc.object());
        jsonScreens = json["screens"].toArray();
    }
}

ScreensConfiguration::~ScreensConfiguration()
{
    const QString dbPath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/");
    QFile f(dbPath + "workspaces");
    if (f.open(QIODevice::WriteOnly)) {
        QJsonObject json;
        json["screens"] = jsonScreens;
        QJsonDocument saveDoc(json);
        f.write(saveDoc.toJson());
    }
}

void ScreensConfiguration::load(Screen *screen)
{
    int workspaces = 2;
    for (auto iter = jsonScreens.begin(); iter != jsonScreens.end(); ++iter) {
        QJsonObject jsonScreen = (*iter).toObject();
        if (jsonScreen["name"] == screen->name()) {
            QJsonValue jsonWorkspaces = jsonScreen["workspaces"];
            workspaces = qMax(jsonWorkspaces.toInt(workspaces), 1);
            break;
        }
    }

    for (int i = 0; i < workspaces; i++) {
        WorkspaceManager::instance()->createWorkspace()->assign(screen->workspaces());
    }
}

void ScreensConfiguration::save(Screen *screen)
{
    QJsonObject newJsonScreen;
    newJsonScreen["name"] = screen->name();
    newJsonScreen["workspaces"] = qMax(screen->workspaces()->rowCount(), 1);

    auto iter = jsonScreens.begin();
    for (; iter != jsonScreens.end(); ++iter) {
        QJsonObject jsonScreen = (*iter).toObject();
        if (jsonScreen["name"] == screen->name()) {
            break;
        }
    }

    if (iter == jsonScreens.end()) {
        jsonScreens.push_back(newJsonScreen);
    } else {
        *iter = newJsonScreen;
    }
}
