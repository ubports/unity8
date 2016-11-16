#include "appdrawermodel.h"
#include "ualwrapper.h"

#include <QDebug>
#include <QDateTime>

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
        m_list.last()->setKeywords(info.keywords);
    }
    qsrand(QDateTime::currentMSecsSinceEpoch() / 100);
}

int AppDrawerModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
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
    case RoleKeywords:
        return m_list.at(index.row())->keywords();
    case RoleUsage:
        // FIXME: u-a-l needs to provide API for usage stats.
        return qrand();
    }

    return QVariant();
}
