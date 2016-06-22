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

#include "applicationmenuregistry.h"

#include <QQmlEngine>
#include <QDebug>


ApplicationMenuRegistry::ApplicationMenuRegistry(QObject *parent)
    : QObject(parent)
{
}

ApplicationMenuRegistry::~ApplicationMenuRegistry()
{
    qDeleteAll(m_appMenus);
    m_appMenus.clear();

    qDeleteAll(m_surfaceMenus);
    m_surfaceMenus.clear();
}

void ApplicationMenuRegistry::RegisterAppMenu(pid_t processId,
                                                const QDBusObjectPath &menuObjectPath,
                                                const QDBusObjectPath &actionObjectPath,
                                                const QString &service)
{
    qDebug() << "RegisterApplicationMenu" << processId << " @ " << service << menuObjectPath.path() << actionObjectPath.path();

    QMultiMap<pid_t, MenuServicePath*>::iterator i = m_appMenus.find(processId);
    while (i != m_appMenus.end() && i.key() == processId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            qWarning() << "Already have a menu for application:" << processId << service << menuObjectPath.path();
            return;
        }
        ++i;
    }

    auto menu = new MenuServicePath(service.toUtf8(), menuObjectPath.path().toUtf8(), actionObjectPath.path().toUtf8());
    QQmlEngine::setObjectOwnership(menu, QQmlEngine::CppOwnership);

    m_appMenus.insert(processId, menu);
    Q_EMIT appMenuRegistered(processId);
}

void ApplicationMenuRegistry::UnregisterAppMenu(pid_t processId, const QDBusObjectPath &menuObjectPath)
{
    qDebug() << "RegisterApplicationMenu" << processId << " @ " << menuObjectPath.path();

    QMultiMap<pid_t, MenuServicePath*>::iterator i = m_appMenus.find(processId);
    while (i != m_appMenus.end() && i.key() == processId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            i.value()->deleteLater();
            m_appMenus.erase(i);
            Q_EMIT appMenuUnregistered(processId);
            break;
        }
        ++i;
    }
}

void ApplicationMenuRegistry::RegisterSurfaceMenu(const QString &surfaceId,
                                           const QDBusObjectPath &menuObjectPath,
                                           const QDBusObjectPath &actionObjectPath,
                                           const QString &service)
{
    qDebug() << "RegisterSurfaceMenu" << surfaceId << " @ " << service << menuObjectPath.path() << actionObjectPath.path();

    QMultiMap<QString, MenuServicePath*>::iterator i = m_surfaceMenus.find(surfaceId);
    while (i != m_surfaceMenus.end() && i.key() == surfaceId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            qWarning() << "Already have a menu for surface:" << surfaceId << service << menuObjectPath.path();
            return;
        }
        ++i;
    }

    auto menu = new MenuServicePath(service.toUtf8(), menuObjectPath.path().toUtf8(), actionObjectPath.path().toUtf8());
    QQmlEngine::setObjectOwnership(menu, QQmlEngine::CppOwnership);

    m_surfaceMenus.insert(surfaceId, menu);
    Q_EMIT surfaceMenuRegistered(surfaceId);
}

void ApplicationMenuRegistry::UnregisterSurfaceMenu(const QString &surfaceId, const QDBusObjectPath &menuObjectPath)
{
    qDebug() << "UnregisterSurfaceMenu" << surfaceId << " @ " << menuObjectPath.path();

    QMultiMap<QString, MenuServicePath*>::iterator i = m_surfaceMenus.find(surfaceId);
    while (i != m_surfaceMenus.end() && i.key() == surfaceId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            i.value()->deleteLater();
            m_surfaceMenus.erase(i);
            Q_EMIT surfaceMenuUnregistered(surfaceId);
            break;
        }
        ++i;
    }
}

QList<QObject*> ApplicationMenuRegistry::getMenusForSurface(const QString &surfaceId)
{
    QList<QObject*> list;

    QMultiMap<QString, MenuServicePath*>::iterator i = m_surfaceMenus.find(surfaceId);
    while (i != m_surfaceMenus.end() && i.key() == surfaceId) {
        list << i.value();
        ++i;
    }
    return list;
}
