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

#include "MirSurfaceItem.h"

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


MirSessionItem *SessionManager::createSession(const QString& name,
                                              const QUrl& screenshot)
{
    MirSessionItem* session = new MirSessionItem(name, screenshot);
    connect(session, &MirSessionItem::aboutToBeDestroyed, this, [&] {
        Q_EMIT sessionStopping(qobject_cast<MirSessionItem*>(sender()));
    });

    Q_EMIT sessionStarting(session);
    return session;
}
