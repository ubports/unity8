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

#include "MirSessionItem.h"
#include "ApplicationInfo.h"
#include "SurfaceManager.h"

#include <QPainter>
#include <QQmlEngine>
#include <QTimer>

MirSessionItem::MirSessionItem(const QString &name,
                               const QUrl& screenshot,
                               QQuickItem *parent)
    : QQuickItem(parent)
    , m_name(name)
    , m_screenshot(screenshot)
    , m_application(nullptr)
    , m_surface(nullptr)
    , m_parentSession(nullptr)
    , m_children(new MirSessionItemModel(this))
{
    qDebug() << "MirSessionItem::MirSessionItem() " << this->name();

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

MirSessionItem::~MirSessionItem()
{
    qDebug() << "MirSessionItem::~MirSessionItem() " << name();

    QList<MirSessionItem*> children(m_children->list());
    for (MirSessionItem* child : children) {
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

void MirSessionItem::release()
{
    qDebug() << "MirSessionItem::release " << name();

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

void MirSessionItem::setApplication(ApplicationInfo* application)
{
    if (m_application == application)
        return;

    if (m_application) {
        disconnect(m_application, 0, this, 0);
    }

    m_application = application;

    if (m_application) {
        connect(m_application, &ApplicationInfo::stateChanged, this, [this](ApplicationInfo::State state) {
            if (state == ApplicationInfo::Running) {
                QTimer::singleShot(500, this, SLOT(createSurface()));
            } else if (state == ApplicationInfo::Stopped) {
                setSurface(nullptr);
            }
        });
    }
}

void MirSessionItem::setSurface(MirSurfaceItem* surface)
{
    qDebug() << "MirSessionItem::setSurface - session=" << name() << "surface=" << surface;
    if (m_surface == surface)
        return;

    if (m_surface) {
        m_surface->setSession(nullptr);
        m_surface->setParent(nullptr);
    }

    m_surface = surface;

    if (m_surface) {
        m_surface->setSession(this);
        m_surface->setParent(this);
    }

    Q_EMIT surfaceChanged(m_surface);
}

void MirSessionItem::setScreenshot(const QUrl& screenshot)
{
    if (screenshot != m_screenshot) {
        m_screenshot = screenshot;
        if (m_surface) {
            m_surface->setScreenshot(m_screenshot);
        }
    }
}

void MirSessionItem::setParentSession(MirSessionItem* session)
{
    if (m_parentSession == session || session == this)
        return;

    m_parentSession = session;
    Q_EMIT parentSessionChanged(session);
}

void MirSessionItem::createSurface()
{
    if (m_surface) return;

    setSurface(SurfaceManager::singleton()->createSurface(name(),
                                   MirSurfaceItem::Normal,
                                   m_application && m_application->fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   m_screenshot));
}

void MirSessionItem::addChildSession(MirSessionItem* session)
{
    insertChildSession(m_children->rowCount(), session);
}

void MirSessionItem::insertChildSession(uint index, MirSessionItem* session)
{
    qDebug() << "MirSessionItem::insertChildSession - " << session->name() << " to " << name() << " @  " << index;

    session->setParentSession(this);
    m_children->insert(index, session);
}

void MirSessionItem::removeChildSession(MirSessionItem* session)
{
    qDebug() << "MirSessionItem::removeChildSession - " << session->name() << " from " << name();

    if (m_children->contains(session)) {
        m_children->remove(session);
        session->setParentSession(nullptr);
    }
}

MirSessionItemModel* MirSessionItem::childSessions() const
{
    return m_children;
}
