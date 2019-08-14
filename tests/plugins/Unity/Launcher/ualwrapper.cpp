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

#include "ualwrapper.h"
#include <QDebug>

UalWrapper* UalWrapper::s_instance = nullptr;
QStringList UalWrapper::s_list;

UalWrapper::UalWrapper(QObject *parent): QObject(parent)
{
    s_instance = this;
}

UalWrapper* UalWrapper::instance()
{
    return s_instance;
}

QStringList UalWrapper::installedApps()
{
    return s_list;
}

UalWrapper::AppInfo UalWrapper::getApplicationInfo(const QString &appId)
{
    AppInfo info;
    info.appId = appId;
    info.name = "App_" + appId;
    info.icon = "/dummy/icon/path/" + appId + ".png";
    info.keywords << QStringLiteral("keyword1") << QStringLiteral("keyword2");
    info.popularity = 1;
    info.valid = true;
    return info;
}

void UalWrapper::addMockApp(const QString &appId)
{
    s_list.append(appId);
}

void UalWrapper::removeMockApp(const QString &appId)
{
    s_list.removeAll(appId);
}
