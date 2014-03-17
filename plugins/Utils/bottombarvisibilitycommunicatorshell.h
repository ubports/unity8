/*
 * Copyright (C) 2012 Canonical, Ltd.
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

#ifndef BOTTOMBARVISIBILITYCOMMUNICATORSHELL_H
#define BOTTOMBARVISIBILITYCOMMUNICATORSHELL_H

#include <QObject>

class QDBusInterface;

/** This is an internal class used to talk with the bottom bar used by either
  * applications or the SDK.
  * There is a method to force the bottom bar to be hidden or otherwise behave as usual
  */

class BottomBarVisibilityCommunicatorShell : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool forceHidden READ forceHidden WRITE setForceHidden NOTIFY forceHiddenChanged)
    Q_PROPERTY(double position READ position WRITE setPosition NOTIFY positionChanged)

    Q_CLASSINFO("D-Bus Interface", "com.canonical.Shell.BottomBarVisibilityCommunicator")
public:
    static BottomBarVisibilityCommunicatorShell& instance() {
        static BottomBarVisibilityCommunicatorShell instance;
        return instance;
    }

    bool forceHidden() const;
    void setForceHidden(bool forceHidden);

    double position() const;
    void setPosition(double position);

Q_SIGNALS:
    void forceHiddenChanged(bool forceHidden);
    void positionChanged(double position);

private:
    BottomBarVisibilityCommunicatorShell();

    bool m_forceHidden;
    double m_position;
};

#endif
