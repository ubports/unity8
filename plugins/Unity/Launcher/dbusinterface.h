/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "launcheritem.h"

#include <QDBusVirtualObject>

class LauncherModel;

class DBusInterface: public QDBusVirtualObject
{
    Q_OBJECT
public:
    DBusInterface(LauncherModel *parent);
    ~DBusInterface();

    // QDBusVirtualObject implementaition
    QString introspect (const QString &path) const override;
    bool handleMessage(const QDBusMessage& message, const QDBusConnection& connection) override;

Q_SIGNALS:
    void countChanged(const QString &appId, int count);
    void countVisibleChanged(const QString &appId, bool countVisible);
    void refreshCalled();

private:
    static QString decodeAppId(const QString& path);
    static QString encodeAppId(const QString& appId);

    void emitPropChangedDbus(const QString& appId, const QString& property, const QVariant &value);

    LauncherModel *m_launcherModel;

};
