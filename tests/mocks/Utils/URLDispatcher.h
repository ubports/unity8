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

#ifndef UNITY_URLDISPATCHER_H
#define UNITY_URLDISPATCHER_H

#include <QObject>
#include <QString>

// This class manages our url-dispatcher interception.  We intercept
// url-dispatcher because rather than spawning the handler for the URL
// in our own session, we want to notify the user session to do it for us
// (and start an unlock in the process).

class URLDispatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    explicit URLDispatcher(QObject *parent=0);

    bool active() const;
    void setActive(bool active);

Q_SIGNALS:
    void urlRequested(const QString &url);
    void activeChanged();

private:
    bool m_active;
};

#endif
