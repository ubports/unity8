/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef APPLICATIONTESTINTERFACE_H
#define APPLICATIONTESTINTERFACE_H

#include <QtDBus/QtDBus>

class ApplicationManager;
class Session;
class MirSurfaceItem;

class ApplicationTestInterface : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity8.Mocks.Application")
public:
    ApplicationTestInterface(QObject* parent = 0);

public Q_SLOTS:
    Q_INVOKABLE quint32 addChildSession(const QString& appId, quint32 existingSessionId, const QString& surfaceImage);
    Q_INVOKABLE quint32 addChildSurface(const QString& appId, quint32 existingSessionId, quint32 existingSurfaceId, const QString& surfaceImage);
    Q_INVOKABLE void removeSession(quint32 sessionId);
    Q_INVOKABLE void removeSurface(quint32 surfaceId);

private:
    QHash<quint32, Session*> m_childSessions;
    QHash<quint32, MirSurfaceItem*> m_childSurfaces;
};

#endif // APPLICATIONTESTINTERFACE_H
