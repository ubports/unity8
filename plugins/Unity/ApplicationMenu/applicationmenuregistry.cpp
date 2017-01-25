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

Q_LOGGING_CATEGORY(UNITY_APPMENU, "unity.appmenu", QtDebugMsg)

#define DEBUG_MSG qCDebug(UNITY_APPMENU).nospace().noquote() << "ApplicationMenuRegistry::"  << __func__
#define WARNING_MSG qCWarning(UNITY_APPMENU).nospace().noquote() << "ApplicationMenuRegistry::" << __func__

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
    DEBUG_MSG << "(pid=" << processId
              << ", menuPath=" << menuObjectPath.path()
              << ", actionPath="  << actionObjectPath.path()
              << ", service=" << service;

    auto i = m_appMenus.find(processId);
    while (i != m_appMenus.end() && i.key() == processId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            WARNING_MSG << "Already have a menu for application (pid= " << processId
                        << ", service=" << service
                        << ", menuPath=" << menuObjectPath.path() << ")";
            return;
        }
        ++i;
    }

    auto menu = new MenuServicePath(service, menuObjectPath, actionObjectPath);
    QQmlEngine::setObjectOwnership(menu, QQmlEngine::CppOwnership);

    m_appMenus.insert(processId, menu);
    Q_EMIT appMenuRegistered(processId);
}

void ApplicationMenuRegistry::UnregisterAppMenu(pid_t processId, const QDBusObjectPath &menuObjectPath)
{
    DEBUG_MSG << "(pid=" << processId
              << ", menuPath=" << menuObjectPath.path();

    auto i = m_appMenus.find(processId);
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
    DEBUG_MSG << "(surfaceId=" << surfaceId
              << ", menuPath=" << menuObjectPath.path()
              << ", actionPath="  << actionObjectPath.path()
              << ", service=" << service;

    auto i = m_surfaceMenus.find(surfaceId);
    while (i != m_surfaceMenus.end() && i.key() == surfaceId) {
        if (i.value()->m_menuPath == menuObjectPath.path().toUtf8()) {
            WARNING_MSG << "Already have a menu for surface (surfaceId= " << surfaceId
                        << ", service=" << service
                        << ", menuPath=" << menuObjectPath.path() << ")";
            return;
        }
        ++i;
    }

    auto menu = new MenuServicePath(service, menuObjectPath, actionObjectPath);
    QQmlEngine::setObjectOwnership(menu, QQmlEngine::CppOwnership);

    m_surfaceMenus.insert(surfaceId, menu);
    Q_EMIT surfaceMenuRegistered(surfaceId);
}

void ApplicationMenuRegistry::UnregisterSurfaceMenu(const QString &surfaceId, const QDBusObjectPath &menuObjectPath)
{
    DEBUG_MSG << "(surfaceId=" << surfaceId
              << ", menuPath=" << menuObjectPath.path();

    auto i = m_surfaceMenus.find(surfaceId);
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

QList<QObject*> ApplicationMenuRegistry::getMenusForSurface(const QString &surfaceId) const
{
    QList<QObject*> list;

    auto i = m_surfaceMenus.find(surfaceId);
    while (i != m_surfaceMenus.constEnd() && i.key() == surfaceId) {
        list << i.value();
        ++i;
    }
    return list;
}
