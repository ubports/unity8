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

#include "Session.h"
#include "ApplicationInfo.h"
#include "SessionManager.h"
#include "SurfaceManager.h"

#include <QPainter>
#include <QQmlEngine>
#include <QTimer>

Session::Session(const QString &name,
                 const QUrl& screenshot,
                 QObject *parent)
    : QObject(parent)
    , m_name(name)
    , m_live(true)
    , m_screenshot(screenshot)
    , m_application(nullptr)
    , m_surface(nullptr)
    , m_parentSession(nullptr)
    , m_children(new SessionModel(this))
{
    qDebug() << "Session::Session() " << this->name();

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Session::~Session()
{
    qDebug() << "Session::~Session() " << name();

    QList<Session*> children(m_children->list());
    for (Session* child : children) {
        delete child;
    }
    if (m_parentSession) {
        m_parentSession->removeChildSession(this);
    }
    if (m_application) {
        m_application->setSession(nullptr);
    }
    delete m_surface;
    delete m_children;
}

void Session::release()
{
    qDebug() << "Session::release " << name();

    if (m_parentSession) {
        m_parentSession->removeChildSession(this);
    }
    if (m_application) {
        m_application->setSession(nullptr);
    }
    if (!parent()) {
        deleteLater();
    }
}

void Session::setApplication(ApplicationInfo* application)
{
    if (m_application == application)
        return;

    m_application = application;
}

void Session::setSurface(MirSurfaceItem* surface)
{
    qDebug() << "Session::setSurface - session=" << name() << "surface=" << surface;
    if (m_surface == surface)
        return;

    if (m_surface) {
        m_surface->setSession(nullptr);
        m_surface->setParent(nullptr);
        Q_EMIT m_surface->deregister();
    }

    m_surface = surface;

    if (m_surface) {
        m_surface->setSession(this);
        m_surface->setParent(this);
        SurfaceManager::singleton()->registerSurface(m_surface);
    }

    Q_EMIT surfaceChanged(m_surface);
}

void Session::setScreenshot(const QUrl& screenshot)
{
    if (screenshot != m_screenshot) {
        m_screenshot = screenshot;
        if (m_surface) {
            m_surface->setScreenshot(m_screenshot);
        }
    }
}

void Session::setLive(bool live)
{
    if (m_live != live) {
        m_live = live;
        Q_EMIT liveChanged(m_live);
    }
}

void Session::setParentSession(Session* session)
{
    if (m_parentSession == session || session == this)
        return;

    m_parentSession = session;
    Q_EMIT parentSessionChanged(session);
}

void Session::createSurface()
{
    if (m_surface) return;

    setSurface(SurfaceManager::singleton()->createSurface(name(),
                                   MirSurfaceItem::Normal,
                                   m_application && m_application->fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   m_screenshot));
}

void Session::addChildSession(Session* session)
{
    insertChildSession(m_children->rowCount(), session);
}

void Session::insertChildSession(uint index, Session* session)
{
    qDebug() << "Session::insertChildSession - " << session->name() << " to " << name() << " @  " << index;

    session->setParentSession(this);
    m_children->insert(index, session);
    SessionManager::singleton()->registerSession(session);
}

void Session::removeChildSession(Session* session)
{
    qDebug() << "Session::removeChildSession - " << session->name() << " from " << name();

    if (m_children->contains(session)) {
        m_children->remove(session);
        session->setParentSession(nullptr);
        Q_EMIT session->deregister();
    }
}

SessionModel* Session::childSessions() const
{
    return m_children;
}
