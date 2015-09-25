/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "globalshortcut.h"
#include "globalshortcutregistry.h"

#include <QDebug>
#include <QQuickItem>

Q_GLOBAL_STATIC(GlobalShortcutRegistry, registry)

GlobalShortcut::GlobalShortcut(QQuickItem *parent)
    : QQuickItem(parent)
{
}

QVariant GlobalShortcut::shortcut() const
{
    return m_shortcut;
}

void GlobalShortcut::setShortcut(const QVariant &shortcut)
{
    if (m_shortcut == shortcut)
        return;

    m_shortcut = shortcut;
    registry->addShortcut(shortcut, this);
    Q_EMIT shortcutChanged(shortcut);
}

bool GlobalShortcut::isActive() const
{
    return m_active;
}

void GlobalShortcut::setActive(bool active)
{
    if (m_active == active)
        return;

    m_active = active;
    Q_EMIT activeChanged(active);
}

void GlobalShortcut::componentComplete()
{
    connect(this, &QQuickItem::windowChanged, this, &GlobalShortcut::setupFilterOnWindow);
}

void GlobalShortcut::keyPressEvent(QKeyEvent * event)
{
    Q_UNUSED(event)
    if (m_active) {
        Q_EMIT triggered(m_shortcut.toString());
    }
}

void GlobalShortcut::setupFilterOnWindow(QQuickWindow *window)
{
    if (!window) {
//        qWarning() << Q_FUNC_INFO << "Failed to setup filter on window";
        return;
    }

    registry->setupFilterOnWindow((qulonglong) window->winId());
}
