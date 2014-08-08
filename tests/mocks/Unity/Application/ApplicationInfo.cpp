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

// unity8
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
    , m_parentItem(0)
{
}

ApplicationInfo::~ApplicationInfo()
{
    if (m_surface) {
        Q_EMIT SurfaceManager::singleton()->surfaceDestroyed(m_surface);
        m_surface->deleteLater();
    }
}

void ApplicationInfo::createSurface()
{
    if (m_surface || state() == ApplicationInfo::Stopped) return;

    setSurface(new MirSurfaceItem(name(),
                                   MirSurfaceItem::Normal,
                                   fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   m_screenshotUrl));
}

void ApplicationInfo::setSurface(MirSurfaceItem* surface)
{
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

void ApplicationInfo::updateScreenshot()
{
    qDebug() << "ApplicationInfo::updateScreenshot()";
    setScreenshot(m_screenshotUrl);
}

void ApplicationInfo::discardScreenshot()
{
    setScreenshot(QUrl());
}

void ApplicationInfo::setIconId(const QString &iconId)
{
    setIcon(QString("file://%1/graphics/applicationIcons/%2@18.png")
            .arg(qmlDirectory())
            .arg(iconId));
}

void ApplicationInfo::setScreenshotId(const QString &screenshotId)
{
    m_screenshotUrl = QString("file://%1/Dash/graphics/phone/screenshots/%2@12.png")
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

        if (m_state == ApplicationInfo::Running) {
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

void ApplicationInfo::setScreenshot(const QUrl &value)
{
    if (value != m_screenshot) {
        m_screenshot = value;
        Q_EMIT screenshotChanged(value);
    }
}

void ApplicationInfo::setFullscreen(bool value)
{
    if (value != m_fullscreen) {
        m_fullscreen = value;
        Q_EMIT fullscreenChanged(value);
    }
}
