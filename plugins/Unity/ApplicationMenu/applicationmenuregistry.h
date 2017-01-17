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

#ifndef APPLICATIONMENUREGISTRY_H
#define APPLICATIONMENUREGISTRY_H

#include <QObject>
#include <QDBusContext>
#include <QDBusObjectPath>
#include <QtQml>

Q_DECLARE_LOGGING_CATEGORY(UNITY_APPMENU)

class MenuServicePath : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QByteArray service MEMBER m_service CONSTANT)
    Q_PROPERTY(QByteArray menuPath MEMBER m_menuPath CONSTANT)
    Q_PROPERTY(QByteArray actionPath MEMBER m_actionPath CONSTANT)
public:
    explicit MenuServicePath(const QString &service,
                             const QDBusObjectPath &menuPath,
                             const QDBusObjectPath &actionPath)
        : m_service(service.toUtf8())
        , m_menuPath(menuPath.path().toUtf8())
        , m_actionPath(actionPath.path().toUtf8())
    {}

    const QByteArray m_service;
    const QByteArray m_menuPath;
    const QByteArray m_actionPath;
};

class ApplicationMenuRegistry : public QObject
{
    Q_OBJECT
public:
    virtual ~ApplicationMenuRegistry();

    // for qml
    Q_INVOKABLE QList<QObject*> getMenusForSurface(const QString &surfaceId) const;

    // for dbus
    void RegisterAppMenu(pid_t processId,
                         const QDBusObjectPath &menuObjectPath,
                         const QDBusObjectPath &actionObjectPath,
                         const QString &service);
    void UnregisterAppMenu(pid_t processId, const QDBusObjectPath &menuObjectPath);

    void RegisterSurfaceMenu(const QString &surfaceId,
                             const QDBusObjectPath &menuObjectPath,
                             const QDBusObjectPath &actionObjectPath,
                             const QString &service);
    void UnregisterSurfaceMenu(const QString &surfaceId, const QDBusObjectPath &menuObjectPath);

Q_SIGNALS:
    void appMenuRegistered(uint processId);
    void appMenuUnregistered(uint processId);

    void surfaceMenuRegistered(const QString& surfaceId);
    void surfaceMenuUnregistered(const QString& surfaceId);

protected:
    explicit ApplicationMenuRegistry(QObject *parent = 0);

    QMultiMap<pid_t, MenuServicePath*> m_appMenus;
    QMultiMap<QString, MenuServicePath*> m_surfaceMenus;
};

#endif // APPLICATIONMENUREGISTRY_H
