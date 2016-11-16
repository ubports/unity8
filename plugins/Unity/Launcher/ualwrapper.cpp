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
            if (!QString::fromStdString(app->appId().package).isEmpty()) {
                appIds << QString::fromStdString(app->appId().package) + QStringLiteral("_") + QString::fromStdString(app->appId().appname);
            } else {
                appIds << QString::fromStdString(app->appId().appname);
            }
        }
    } catch(std::runtime_error &e) {
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
    } catch(std::runtime_error &e) {
        qWarning() << "ubuntu-app-launch threw an exception getting app info for appId:" << appId << ":" << e.what();
    }

    return info;
}
