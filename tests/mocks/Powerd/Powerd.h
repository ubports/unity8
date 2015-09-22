/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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
 *
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_MOCK_POWERD_H
#define UNITY_MOCK_POWERD_H

#include <QtCore/QObject>

class Powerd: public QObject
{
    Q_OBJECT
    Q_ENUMS(Status)
    Q_ENUMS(DisplayStateChangeReason)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)

public:
    enum DisplayStateChangeReason {
        Unknown         = 0,
        Inactivity      = 1, // Display changed state due to inactivity
        PowerKey        = 2, // Display changed state due to user pressing power key
        Proximity       = 3, // Display changed state due to proximity events
    };

    enum Status {
        Off,
        On,
    };

    explicit Powerd(QObject *parent = 0);

    Status status() const;

    // Not exposed via Q_PROPERTY because we need the 'reason' argument too
    Q_INVOKABLE void setStatus(Status status, DisplayStateChangeReason reason);

Q_SIGNALS:
    void statusChanged(DisplayStateChangeReason reason);

private:
    Status m_status;
};

#endif
