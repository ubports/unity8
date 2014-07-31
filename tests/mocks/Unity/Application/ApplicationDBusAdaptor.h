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

#ifndef APPLICATIONDBUSADAPTOR_H
#define APPLICATIONDBUSADAPTOR_H

#include <QtDBus/QtDBus>

class ApplicationManager;
class SurfaceManager;
class MirSurfaceItem;

class ApplicationDBusAdaptor : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity8.Mocks.Application")
public:
    ApplicationDBusAdaptor(ApplicationManager* applicationManager);

public Q_SLOTS:
    quint32 addChildSurface(const QString& appId, const QString& surfaceImage);
    void removeChildSurface(int surfaceId);

private:
    ApplicationManager* m_applicationManager;

    QHash<quint32, MirSurfaceItem*> m_childItems;
};

#endif // APPLICATIONDBUSADAPTOR_H
