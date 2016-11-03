#include "appdrawermodel.h"
#include "ualwrapper.h"

#include <QDebug>

#include <ubuntu-app-launch/registry.h>

AppDrawerModel::AppDrawerModel(QObject *parent):
    AppDrawerModelInterface(parent)
{
    Q_FOREACH (const QString &appId, UalWrapper::installedApps()) {
        UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
        if (!info.valid) {
            qWarning() << "Failed to get app info for app" << appId;
            continue;
        }
        m_list.append(new LauncherItem(appId, info.name, info.icon, this));
        qDebug() << "added" << appId;
    }
}

int AppDrawerModel::rowCount(const QModelIndex &parent) const
{
    return m_list.count();
}

QVariant AppDrawerModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleAppId:
        return m_list.at(index.row())->appId();
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    }

    return QVariant();
}
