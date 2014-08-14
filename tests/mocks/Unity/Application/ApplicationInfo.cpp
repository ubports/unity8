/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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

#include "ApplicationInfo.h"
#include "MirSurfaceItem.h"
#include "SurfaceManager.h"

#include <paths.h>

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_surface(0)
    , m_manualSurfaceCreation(false)
    , m_parentItem(0)
{
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_surface(0)
    , m_manualSurfaceCreation(false)
    , m_parentItem(0)
{
}

ApplicationInfo::~ApplicationInfo()
{
    if (m_surface) {
        // break the cyclic reference before destroying it
        m_surface->setApplication(nullptr);

        Q_EMIT SurfaceManager::singleton()->surfaceDestroyed(m_surface);
        m_surface->deleteLater();
    }
}

void ApplicationInfo::createSurface()
{
    if (m_surface || state() == ApplicationInfo::Stopped) return;

    QUrl screenshotUrl = QString("file://%1").arg(m_screenshotFileName);

    setSurface(new MirSurfaceItem(name(),
                                   MirSurfaceItem::Normal,
                                   fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   screenshotUrl));
}

void ApplicationInfo::setSurface(MirSurfaceItem* surface)
{
    qDebug() << "Application::setSurface - appId=" << appId() << "surface=" << surface;
    if (m_surface == surface)
        return;

    if (m_surface) {
        m_surface->setApplication(nullptr);
        m_surface->setParent(nullptr);
        SurfaceManager::singleton()->unregisterSurface(m_surface);
    }

    m_surface = surface;

    if (m_surface) {
        m_surface->setApplication(this);
        m_surface->setParent(this);
        SurfaceManager::singleton()->registerSurface(m_surface);
    }

    Q_EMIT surfaceChanged(m_surface);
    SurfaceManager::singleton()->registerSurface(m_surface);
}

void ApplicationInfo::addPromptSurface(MirSurfaceItem* surface)
{
    qDebug() << "ApplicationInfo::addPromptSurface " << surface->name() << " to " << name();
    if (surface == m_surface || m_promptSurfaces.contains(surface)) return;

    surface->setApplication(this);
    m_promptSurfaces.append(surface);
    Q_EMIT promptSurfacesChanged();
}

void ApplicationInfo::removeSurface(MirSurfaceItem* surface)
{
    if (m_surface == surface) {
        setSurface(nullptr);
    } else if (m_promptSurfaces.contains(surface)) {
        qDebug() << "Application::removeSurface " << surface->name() << " from " << name();

        m_promptSurfaces.removeAll(surface);
        surface->setApplication(nullptr);

        Q_EMIT promptSurfacesChanged();
    }
}

QList<MirSurfaceItem*> ApplicationInfo::promptSurfaceList() const
{
    return m_promptSurfaces;
}

QQmlListProperty<MirSurfaceItem> ApplicationInfo::promptSurfaces()
{
    return QQmlListProperty<MirSurfaceItem>(this,
                                            0,
                                            ApplicationInfo::promptSurfaceCount,
                                            ApplicationInfo::promptSurfaceAt);
}

int ApplicationInfo::promptSurfaceCount(QQmlListProperty<MirSurfaceItem> *prop)
{
    ApplicationInfo *p = qobject_cast<ApplicationInfo*>(prop->object);
    return p->m_promptSurfaces.count();
}

MirSurfaceItem* ApplicationInfo::promptSurfaceAt(QQmlListProperty<MirSurfaceItem> *prop, int index)
{
    ApplicationInfo *p = qobject_cast<ApplicationInfo*>(prop->object);

    if (index < 0 || index >= p->m_promptSurfaces.count())
        return nullptr;
    return p->m_promptSurfaces[index];
}

void ApplicationInfo::setIconId(const QString &iconId)
{
    setIcon(QString("file://%1/graphics/applicationIcons/%2@18.png")
            .arg(qmlDirectory())
            .arg(iconId));
}

void ApplicationInfo::setScreenshotId(const QString &screenshotId)
{
    m_screenshotFileName = QString("%1/Dash/graphics/phone/screenshots/%2@12.png")
            .arg(qmlDirectory())
            .arg(screenshotId);
}

void ApplicationInfo::setName(const QString &value)
{
    if (value != m_name) {
        m_name = value;
        Q_EMIT nameChanged(value);
    }
}

void ApplicationInfo::setIcon(const QUrl &value)
{
    if (value != m_icon) {
        m_icon = value;
        Q_EMIT iconChanged(value);
    }
}

void ApplicationInfo::setStage(Stage value)
{
    if (value != m_stage) {
        m_stage = value;
        Q_EMIT stageChanged(value);
    }
}

void ApplicationInfo::setState(State value)
{
    if (value != m_state) {
        m_state = value;
        Q_EMIT stateChanged(value);

        if (!m_manualSurfaceCreation && m_state == ApplicationInfo::Running) {
            QTimer::singleShot(1000, this, SLOT(createSurface()));
        }
    }
}

void ApplicationInfo::setFocused(bool value)
{
    if (value != m_focused) {
        m_focused = value;
        Q_EMIT focusedChanged(value);
    }
}

void ApplicationInfo::setFullscreen(bool value)
{
    if (value != m_fullscreen) {
        m_fullscreen = value;
        Q_EMIT fullscreenChanged(value);
    }
}

void ApplicationInfo::setManualSurfaceCreation(bool value)
{
    if (value != m_manualSurfaceCreation) {
        m_manualSurfaceCreation = value;
        Q_EMIT manualSurfaceCreationChanged(value);
    }
}
