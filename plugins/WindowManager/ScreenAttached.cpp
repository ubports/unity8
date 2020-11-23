/*
 * Copyright (C) 2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ScreenAttached.h"
#include "ScreenWindow.h"
#include "Screens.h"

#include <QQuickItem>
#include <QScreen>

namespace
{
QQuickItem* itemForOwner(QObject* obj) {
    QObject* parent = obj;
    while(parent) {
        auto item = qobject_cast<QQuickItem*>(parent);
        if (item) return item;
        parent = parent->parent();
    }
    return nullptr;
}
} // namesapce

ScreenAttached::ScreenAttached(QObject *owner)
    : Screen(owner)
    , m_window(nullptr)
{
    if (auto item = itemForOwner(owner)) {
        connect(item, &QQuickItem::windowChanged, this, &ScreenAttached::windowChanged);
        windowChanged(item->window());
    } else if (auto window = qobject_cast<QQuickWindow*>(owner)) {
        windowChanged(window);
    }
}

WorkspaceModel *ScreenAttached::workspaces() const
{
    if (!m_screen) return nullptr;
    return m_screen->workspaces();
}

Workspace *ScreenAttached::currentWorkspace() const
{
    if (!m_screen) return nullptr;
    return m_screen->currentWorkspace();
}

void ScreenAttached::setCurrentWorkspace(Workspace *workspace)
{
    if (!m_screen) return;
    return m_screen->setCurrentWorkspace(workspace);
}

void ScreenAttached::windowChanged(QQuickWindow *window)
{
    if (m_window) {
        disconnect(m_window, &QWindow::screenChanged, this, &ScreenAttached::screenChanged);
    }

    m_window = window;
    auto screenWindow = qobject_cast<ScreenWindow*>(window);

    if (screenWindow) {
        screenChanged2(screenWindow->screenWrapper());
        connect(screenWindow, &ScreenWindow::screenWrapperChanged, this, &ScreenAttached::screenChanged2);
    } else {
        screenChanged(window ? window->screen() : NULL);
        if (window) {
            connect(window, &QWindow::screenChanged, this, &ScreenAttached::screenChanged);
        }
    }
}

void ScreenAttached::screenChanged(QScreen *qscreen)
{
    // Find a screen that matches.
    // Should only get here in mocks if we don't have a ScreenWindow
    Screen* screen{nullptr};
    Q_FOREACH(auto s, ConcreteScreens::self()->list()) {
        if (s->qscreen() == qscreen) {
            screen = s;
        }
    }
    screenChanged2(screen);
}

void ScreenAttached::screenChanged2(Screen* screen)
{
    if (screen == m_screen) return;

    Screen* oldScreen = m_screen;
    m_screen = screen;

    if (oldScreen)
        oldScreen->disconnect(this);

    if (!screen)
        return; //Don't bother emitting signals, because the new values are garbage anyways

    if (!oldScreen || screen->isActive() != oldScreen->isActive())
        Q_EMIT activeChanged(screen->isActive());
    if (!oldScreen || screen->used() != oldScreen->used())
        Q_EMIT usedChanged();
    if (!oldScreen || screen->name() != oldScreen->name())
        Q_EMIT nameChanged();
    if (!oldScreen || screen->outputType() != oldScreen->outputType())
        Q_EMIT outputTypeChanged();
    if (!oldScreen || screen->scale() != oldScreen->scale())
        Q_EMIT scaleChanged();
    if (!oldScreen || screen->formFactor() != oldScreen->formFactor())
        Q_EMIT formFactorChanged();
    if (!oldScreen || screen->powerMode() != oldScreen->powerMode())
        Q_EMIT powerModeChanged();
    if (!oldScreen || screen->orientation() != oldScreen->orientation())
        Q_EMIT orientationChanged();
    if (!oldScreen || screen->position() != oldScreen->position())
        Q_EMIT positionChanged();
    if (!oldScreen || screen->currentModeIndex() != oldScreen->currentModeIndex())
        Q_EMIT currentModeIndexChanged();
    if (!oldScreen || screen->physicalSize() != oldScreen->physicalSize())
        Q_EMIT physicalSizeChanged();
    if (!oldScreen || screen->currentWorkspace() != oldScreen->currentWorkspace())
        Q_EMIT currentWorkspaceChanged(currentWorkspace());

    if (oldScreen) {
        QVector<qtmir::ScreenMode*> oldModes;
        auto oldModesQmlList = oldScreen->availableModes();
        for (int i = 0; i < oldModesQmlList.count(&oldModesQmlList); i++) {
            oldModes << oldModesQmlList.at(&oldModesQmlList, i);
        }

        QVector<qtmir::ScreenMode*> newModes;
        auto newModesQmlList = screen->availableModes();
        for (int i = 0; i < newModesQmlList.count(&newModesQmlList); i++) {
            newModes << newModesQmlList.at(&newModesQmlList, i);
        }

        if (newModes != newModes) {
            Q_EMIT availableModesChanged();
        }
    } else {
        Q_EMIT availableModesChanged();
    }

    connectToScreen(screen);
}

ScreenAttached *WMScreen::qmlAttachedProperties(QObject *owner)
{
    return new ScreenAttached(owner);
}
