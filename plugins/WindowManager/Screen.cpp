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

#include "Screen.h"
#include "Screens.h"
#include "WorkspaceManager.h"
#include "Workspace.h"

ScreenInterface::ScreenInterface(QObject *parent)
    : QObject(parent)
{
}

void ScreenInterface::connectToScreen(qtmir::Screen *screen)
{
    m_wrapped = screen;
    connect(screen, &qtmir::Screen::usedChanged, this, &ScreenInterface::usedChanged);
    connect(screen, &qtmir::Screen::nameChanged, this, &ScreenInterface::nameChanged);
    connect(screen, &qtmir::Screen::outputTypeChanged, this, &ScreenInterface::outputTypeChanged);
    connect(screen, &qtmir::Screen::scaleChanged, this, &ScreenInterface::scaleChanged);
    connect(screen, &qtmir::Screen::formFactorChanged, this, &ScreenInterface::formFactorChanged);
    connect(screen, &qtmir::Screen::physicalSizeChanged, this, &ScreenInterface::physicalSizeChanged);
    connect(screen, &qtmir::Screen::positionChanged, this, &ScreenInterface::positionChanged);
    connect(screen, &qtmir::Screen::activeChanged, this, &ScreenInterface::activeChanged);
    connect(screen, &qtmir::Screen::currentModeIndexChanged, this, &ScreenInterface::currentModeIndexChanged);
    connect(screen, &qtmir::Screen::availableModesChanged, this, &ScreenInterface::availableModesChanged);
}

qtmir::OutputId ScreenInterface::outputId() const
{
    if (!m_wrapped) return qtmir::OutputId(-1);
    return m_wrapped->outputId();
}

bool ScreenInterface::used() const
{
    if (!m_wrapped) return false;
    return m_wrapped->used();
}

QString ScreenInterface::name() const
{
    if (!m_wrapped) return QString();
    return m_wrapped->name();
}

float ScreenInterface::scale() const
{
    if (!m_wrapped) return 1.0;
    return m_wrapped->scale();
}

QSizeF ScreenInterface::physicalSize() const
{
    if (!m_wrapped) return QSizeF();
    return m_wrapped->physicalSize();
}

qtmir::FormFactor ScreenInterface::formFactor() const
{
    if (!m_wrapped) return qtmir::FormFactorUnknown;
    return m_wrapped->formFactor();
}

qtmir::OutputTypes ScreenInterface::outputType() const
{
    if (!m_wrapped) return qtmir::Unknown;
    return m_wrapped->outputType();
}

MirPowerMode ScreenInterface::powerMode() const
{
    if (!m_wrapped) return mir_power_mode_on;
    return m_wrapped->powerMode();
}

Qt::ScreenOrientation ScreenInterface::orientation() const
{
    if (!m_wrapped) return Qt::PrimaryOrientation;
    return m_wrapped->orientation();
}

QPoint ScreenInterface::position() const
{
    if (!m_wrapped) return QPoint();
    return m_wrapped->position();
}

QQmlListProperty<qtmir::ScreenMode> ScreenInterface::availableModes()
{
    if (!m_wrapped) return QQmlListProperty<qtmir::ScreenMode>();
    return m_wrapped->availableModes();
}

uint ScreenInterface::currentModeIndex() const
{
    if (!m_wrapped) return -1;
    return m_wrapped->currentModeIndex();
}

bool ScreenInterface::isActive() const
{
    if (!m_wrapped) return false;
    return m_wrapped->isActive();
}

void ScreenInterface::activate()
{
    setActive(true);
}

void ScreenInterface::setActive(bool active)
{
    if (!m_wrapped) return;
    m_wrapped->setActive(active);
}

QScreen *ScreenInterface::qscreen() const
{
    if (!m_wrapped) return nullptr;
    return m_wrapped->qscreen();
}

qtmir::ScreenConfiguration *ScreenInterface::beginConfiguration() const
{
    if (!m_wrapped) return nullptr;
    return m_wrapped->beginConfiguration();
}

bool ScreenInterface::applyConfiguration(qtmir::ScreenConfiguration *configuration)
{
    if (!m_wrapped) return false;
    return m_wrapped->applyConfiguration(configuration);
}

void ScreenInterface::sync(ScreenInterface *proxy)
{
    if (!proxy) return;
    workspaces()->sync(proxy->workspaces());
}

Screen::Screen(qtmir::Screen* wrapped)
    : m_workspaces(new WorkspaceModel)
{
    connectToScreen(wrapped);

    // Connect the active workspace to activate the screen.
    connect(m_workspaces.data(), &WorkspaceModel::workspaceInserted, this, [this](int, Workspace* workspace) {
        connect(workspace, &Workspace::activeChanged, this, [this, workspace](bool active) {
            if (active) {
                setCurrentWorkspace(workspace);
                activate();
            }
        });
        if (workspace->isActive()) {
            activate();
            setCurrentWorkspace(workspace);
        }
        if (!m_currentWorspace) {
            setCurrentWorkspace(workspace);
        }
    });
    connect(m_workspaces.data(), &WorkspaceModel::workspaceRemoved, this, [this](Workspace* workspace) {
        disconnect(workspace, &Workspace::activeChanged, this, 0);
        if (workspace == m_currentWorspace) {
            resetCurrentWorkspace();
        }
    });
    connect(this, &Screen::activeChanged, this, [this](bool active) {
        if (active && m_currentWorspace) {
            m_currentWorspace->activate();
        }
    });

    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
}

void Screen::resetCurrentWorkspace()
{
    auto newCurrent = m_workspaces->rowCount() > 0 ? m_workspaces->get(0) : nullptr;
    if (m_currentWorspace != newCurrent) {
        m_currentWorspace = newCurrent;
        Q_EMIT currentWorkspaceChanged(newCurrent);
    }
}


WorkspaceModel *Screen::workspaces() const
{
    return m_workspaces.data();
}

Workspace *Screen::currentWorkspace() const
{
    return m_currentWorspace.data();
}

void Screen::setCurrentWorkspace(Workspace *workspace)
{
    if (m_currentWorspace != workspace) {
        m_currentWorspace = workspace;
        Q_EMIT currentWorkspaceChanged(workspace);
    }
}

ScreenProxy::ScreenProxy(ScreenInterface *const screen)
    : m_workspaces(new WorkspaceModelProxy(screen->workspaces()))
    , m_original(screen)
{
    connectToScreen(screen->wrapped());

    auto updateCurrentWorkspaceFn = [this](Workspace* realWorkspace) {
        Q_FOREACH(Workspace* workspace, m_workspaces->list()) {
            auto p = qobject_cast<WorkspaceProxy*>(workspace);
            if (p && p->proxyObject() == realWorkspace) {
               if (m_currentWorspace != p) {
                   m_currentWorspace = p;
                   Q_EMIT currentWorkspaceChanged(p);
               }
            }
        }
    };
    connect(screen, &ScreenInterface::currentWorkspaceChanged, this, updateCurrentWorkspaceFn);
    updateCurrentWorkspaceFn(screen->currentWorkspace());
}

WorkspaceModel *ScreenProxy::workspaces() const
{
    return m_workspaces.data();
}

Workspace *ScreenProxy::currentWorkspace() const
{
    return m_currentWorspace.data();
}

void ScreenProxy::setCurrentWorkspace(Workspace *workspace)
{
    auto p = qobject_cast<WorkspaceProxy*>(workspace);
    if (p) {
        m_original->setCurrentWorkspace(p->proxyObject());
    }
}

void ScreenProxy::addWorkspace()
{
    (new WorkspaceProxy(WorkspaceManager::instance()->createWorkspace()))->assign(workspaces());
}
