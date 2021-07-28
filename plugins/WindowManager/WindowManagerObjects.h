/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#ifndef WINDOWMANAGEROBJECTS_H
#define WINDOWMANAGEROBJECTS_H

#include <QObject>

#include "WindowManagerGlobal.h"

namespace lomiri {
    namespace shell {
        namespace application {
            class SurfaceManagerInterface;
            class ApplicationManagerInterface;
        }
    }
}

class WINDOWMANAGERQML_EXPORT WindowManagerObjects : public QObject
{
    Q_OBJECT

    Q_PROPERTY(lomiri::shell::application::SurfaceManagerInterface* surfaceManager
            READ surfaceManager
            WRITE setSurfaceManager
            NOTIFY surfaceManagerChanged)

    Q_PROPERTY(lomiri::shell::application::ApplicationManagerInterface* applicationManager
            READ applicationManager
            WRITE setApplicationManager
            NOTIFY applicationManagerChanged)
public:
    explicit WindowManagerObjects(QObject *parent = 0);

    static WindowManagerObjects *instance();

    lomiri::shell::application::SurfaceManagerInterface *surfaceManager() const { return m_surfaceManager; }
    void setSurfaceManager(lomiri::shell::application::SurfaceManagerInterface*);

    lomiri::shell::application::ApplicationManagerInterface *applicationManager() const { return m_applicationManager; }
    void setApplicationManager(lomiri::shell::application::ApplicationManagerInterface*);

Q_SIGNALS:
    void surfaceManagerChanged(lomiri::shell::application::SurfaceManagerInterface*);
    void applicationManagerChanged(lomiri::shell::application::ApplicationManagerInterface*);

private:
    lomiri::shell::application::SurfaceManagerInterface* m_surfaceManager;
    lomiri::shell::application::ApplicationManagerInterface* m_applicationManager;
};

#endif // WINDOWMANAGEROBJECTS_H
