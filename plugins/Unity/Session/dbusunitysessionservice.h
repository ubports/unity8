/* -*- mode: c++; indent-tabs-mode: nil; tab-width: 4 -*- */
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

#ifndef DBUSUNITYSESSIONSERVICE_H_1397562297
#define DBUSUNITYSESSIONSERVICE_H_1397562297

#include <QObject>

/**
 * DBusUnitySessionService provides com.canonical.Unity.Session dbus
 * interface.
 *
 * com.canonical.Unity.Session interface provides public methods
 * and signals to handle Logout/Reboot/Shutdown.
 */
class DBusUnitySessionService : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity.Session")

public:
    DBusUnitySessionService();
    explicit DBusUnitySessionService(QObject* parent);
    ~DBusUnitySessionService();

Q_SIGNALS:
    /**
     * logoutRequested signal
     *
     * This signal is emitted when some applications request the system to
     * logout.
     * @param have_inhibitors if there are any special running applications
     *        which inhibit the logout.
     */
    void logoutRequested(bool have_inhibitors);

    /**
     * logoutReady signal
     *
     * This signal is emitted when all the apps are closed. And the system
     * is safe to logout.
     */
    void logoutReady();

public Q_SLOTS:
    /**
     * Logout the system.
     *
     * This method directly logout the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestLogout() to ask the user to decide logout or not.
     * This method will stop all the running applications and then signal
     * logoutReady when all the apps stopped.
     */
    Q_SCRIPTABLE void Logout();

    /**
     * Issue a logout request.
     *
     * This method emit the logoutRequested signal to the shell with a boolean
     * which indicates if there's any inhibitors. The shell should receive
     * this signal and display a dialog to ask the user to confirm the logout
     * action. If confirmed, shell can call Logout() method to kill the apps
     * and then logout
     */
    Q_SCRIPTABLE void RequestLogout();

};

#endif // DBUSUNITYSESSIONSERVICE_H_1397562297
