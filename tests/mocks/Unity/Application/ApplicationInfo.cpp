/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    ,m_appId(appId)
    ,m_stage(MainStage)
    ,m_state(Starting)
    ,m_focused(false)
    ,m_fullscreen(false)
    ,m_windowItem(0)
    ,m_windowComponent(0)
    ,m_parentItem(0)
{
    QTimer::singleShot(300, this, SLOT(setRunning()));
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
     ,m_stage(MainStage)
     ,m_state(Starting)
     ,m_focused(false)
     ,m_fullscreen(false)
     ,m_windowItem(0)
     ,m_windowComponent(0)
     ,m_parentItem(0)
{
    QTimer::singleShot(300, this, SLOT(setRunning()));
}

void ApplicationInfo::onWindowComponentStatusChanged(QQmlComponent::Status status)
{
    if (status == QQmlComponent::Ready && !m_windowItem)
        doCreateWindowItem();
}

void ApplicationInfo::setRunning()
{
    m_state = Running;
    Q_EMIT stateChanged();
}

void ApplicationInfo::createWindowComponent()
{
    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQmlEngine *engine = quickView->engine();

    m_windowComponent = new QQmlComponent(engine, this);
    m_windowComponent->setData(m_windowQml.toLatin1(), QUrl());
}

void ApplicationInfo::doCreateWindowItem()
{
    m_windowItem = qobject_cast<QQuickItem *>(m_windowComponent->create());
    m_windowItem->setParentItem(m_parentItem);
}

void ApplicationInfo::createWindowItem()
{
    if (!m_windowComponent)
        createWindowComponent();

    // only create the windowItem once the component is ready
    if (!m_windowComponent->isReady()) {
        connect(m_windowComponent, &QQmlComponent::statusChanged,
                this, &ApplicationInfo::onWindowComponentStatusChanged);
    } else {
        doCreateWindowItem();
    }
}

void ApplicationInfo::showWindow(QQuickItem *parent)
{
    m_parentItem = parent;

    if (!m_windowItem)
        createWindowItem();

    if (m_windowItem) {
        m_windowItem->setVisible(true);
    }
}

void ApplicationInfo::hideWindow()
{
    if (!m_windowItem)
        return;

    m_windowItem->setVisible(false);
}
