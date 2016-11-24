/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include <QDebug>

#include "ualwrapper.h"

#include <ubuntu-app-launch/registry.h>
using namespace ubuntu::app_launch;

UalWrapper::UalWrapper(QObject *parent):
    QObject(parent)
{

}

QStringList UalWrapper::installedApps()
{
    QStringList appIds;
    try {
        for (const std::shared_ptr<Application> &app : Registry::installedApps()) {
            if (!app->appId().package.value().empty()) {
                appIds << QString::fromStdString(app->appId().package.value() + "_" + app->appId().appname.value());
            } else {
                appIds << QString::fromStdString(app->appId().appname);
            }
        }
    } catch (const std::runtime_error &e) {
        qWarning() << "ubuntu-all-launch threw an exception listing apps:" << e.what();
    }

    return appIds;
}

UalWrapper::AppInfo UalWrapper::getApplicationInfo(const QString &appId)
{
    AppInfo info;

    try {
        AppID ualAppId = AppID::find(appId.toStdString());
        if (ualAppId.empty()) {
            qWarning() << "Empty ualAppId result for" << appId;
            return info;
        }

        std::shared_ptr<Application> ualApp;
        ualApp = Application::create(ualAppId, Registry::getDefault());

        info.name = QString::fromStdString(ualApp->info()->name());
        info.icon = QString::fromStdString(ualApp->info()->iconPath());
        for (const std::string &keyword : ualApp->info()->keywords().value()) {
            info.keywords << QString::fromStdString(keyword);
        }
        info.valid = true;
    } catch (const std::runtime_error &e) {
        qWarning() << "ubuntu-app-launch threw an exception getting app info for appId:" << appId << ":" << e.what();
    }

    return info;
}
