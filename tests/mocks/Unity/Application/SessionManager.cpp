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

#include "SessionManager.h"

#include "Session.h"

SessionManager *SessionManager::the_session_manager = nullptr;

SessionManager *SessionManager::singleton()
{
    if (!the_session_manager) {
        the_session_manager = new SessionManager();
    }
    return the_session_manager;
}

SessionManager::SessionManager(QObject *parent) :
    QObject(parent)
{
}


Session *SessionManager::createSession(const QString& name,
                                       const QUrl& screenshot)
{
    Session* session = new Session(name, screenshot);
    Q_EMIT sessionStarting(session);
    return session;
}

void SessionManager::registerSession(Session *session)
{
    connect(session, &Session::deregister, this, [this] {
        Session* session = qobject_cast<Session*>(sender());

        disconnect(session, 0, this, 0);
        Q_EMIT sessionStopping(session);
    });
}
