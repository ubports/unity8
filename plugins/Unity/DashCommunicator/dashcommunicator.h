/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DASHCOMMUNICATOR_H
#define DASHCOMMUNICATOR_H

#include <QObject>

class QDBusInterface;

namespace unity {
namespace shell {
namespace application {
class ApplicationManagerInterface;
class ApplicationInfoInterface;
}
}
}

class DashCommunicator: public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity.DashCommunicator")

    Q_PROPERTY(unity::shell::application::ApplicationManagerInterface* applicationManager
               READ applicationManager WRITE setApplicationManager NOTIFY applicationManagerChanged)
public:
    DashCommunicator(QObject *parent = 0);
    ~DashCommunicator();

    unity::shell::application::ApplicationManagerInterface* applicationManager() const;
    void setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager);

Q_SIGNALS:
    void applicationManagerChanged();

public Q_SLOTS:
    void setCurrentScope(const QString &scopeId, bool animate, bool isSwipe);

private Q_SLOTS:
    void connectToDash();
    void applicationAdded(const QString &appId);
    void applicationRemoved(const QString &appId);

private:
    QDBusInterface *m_dashInterface;
    unity::shell::application::ApplicationManagerInterface* m_applicationManager;
    unity::shell::application::ApplicationInfoInterface* m_dash;
};

#endif
