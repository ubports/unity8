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

#ifndef DBUSUNITYSESSIONSERVICE_H
#define DBUSUNITYSESSIONSERVICE_H

#include "unitydbusobject.h"

/**
 * DBusUnitySessionService provides com.canonical.Unity.Session dbus
 * interface.
 *
 * com.canonical.Unity.Session interface provides public methods
 * and signals to handle Logout/Reboot/Shutdown.
 */
class DBusUnitySessionService : public UnityDBusObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity.Session")

public:
    DBusUnitySessionService();
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
     * rebootRequested signal
     *
     * This signal is emitted when some applications request the system to
     * reboot.
     * @param have_inhibitors if there are any special running applications
     *        which inhibit the reboot.
     */
    void rebootRequested(bool have_inhibitors);

    /**
     * shutdownRequested signal
     *
     * This signal is emitted when some applications request the system to
     * shutdown.
     * @param have_inhibitors if there are any special running applications
     *        which inhibit the shutdown.
     */
    void shutdownRequested(bool have_inhibitors);


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
     */
    Q_SCRIPTABLE void Logout();

    /**
     * Reboot the system.
     *
     * This method directly reboot the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestReboot() to ask the user to decide reboot or not.
     */
    Q_SCRIPTABLE void Reboot();

    /**
     * Shutdown the system.
     *
     * This method directly shutdown the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestShutdown() to ask the user to decide shutdown or not.
     */
    Q_SCRIPTABLE void Shutdown();

    /**
     * Issue a logout request.
     *
     * This method emit the logoutRequested signal to the shell with a boolean
     * which indicates if there's any inhibitors. The shell should receive
     * this signal and display a dialog to ask the user to confirm the logout
     * action. If confirmed, shell can call Logout() method to logout.
     */
    Q_SCRIPTABLE void RequestLogout();

    /**
     * Issue a reboot request.
     *
     * This method emit the rebootRequested signal to the shell with a boolean
     * which indicates if there's any inhibitors. The shell should receive
     * this signal and display a dialog to ask the user to confirm the reboot
     * action. If confirmed, shell can call Reboot() method to reboot
     */
    Q_SCRIPTABLE void RequestReboot();

    /**
     * Issue a shutdown request.
     *
     * This method emit the shutdownRequested signal to the shell with a
     * boolean which indicates if there's any inhibitors.
     * The shell should receive
     * this signal and display a dialog to ask the user to confirm the reboot
     * action. If confirmed, shell can call Shutdown() method to reboot
     */
    Q_SCRIPTABLE void RequestShutdown();

};

#endif // DBUSUNITYSESSIONSERVICE_H
