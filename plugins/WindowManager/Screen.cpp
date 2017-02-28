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
#include "WorkspaceModel.h"
#include "WorkspaceManager.h"
#include "Workspace.h"

Screen::Screen(qtmir::Screen* screen)
    : m_wrapped(screen)
    , m_workspaces(new WorkspaceModel)
{
    connect(m_wrapped, &qtmir::Screen::usedChanged, this, &Screen::usedChanged);
    connect(m_wrapped, &qtmir::Screen::nameChanged, this, &Screen::nameChanged);
    connect(m_wrapped, &qtmir::Screen::outputTypeChanged, this, &Screen::outputTypeChanged);
    connect(m_wrapped, &qtmir::Screen::scaleChanged, this, &Screen::scaleChanged);
    connect(m_wrapped, &qtmir::Screen::formFactorChanged, this, &Screen::formFactorChanged);
    connect(m_wrapped, &qtmir::Screen::physicalSizeChanged, this, &Screen::physicalSizeChanged);
    connect(m_wrapped, &qtmir::Screen::positionChanged, this, &Screen::positionChanged);
    connect(m_wrapped, &qtmir::Screen::activeChanged, this, &Screen::activeChanged);
    connect(m_wrapped, &qtmir::Screen::currentModeIndexChanged, this, &Screen::currentModeIndexChanged);
    connect(m_wrapped, &qtmir::Screen::availableModesChanged, this, &Screen::availableModesChanged);

    // Connect the active workspace to activate the screen.
    connect(m_workspaces.data(), &WorkspaceModel::workspaceAdded, this, [this](Workspace* workspace) {
        connect(workspace, &Workspace::activeChanged, this, [this](bool active) {
            if (active) activate();
        });
        if (workspace->isActive()) activate();
    });
    connect(m_workspaces.data(), &WorkspaceModel::workspaceRemoved, this, [this](Workspace* workspace) {
        disconnect(workspace, &Workspace::activeChanged, this, 0);
    });

    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
}

qtmir::OutputId Screen::outputId() const
{
    return m_wrapped->outputId();
}

bool Screen::used() const
{
    return m_wrapped->used();
}

QString Screen::name() const
{
    return m_wrapped->name();
}

float Screen::scale() const
{
    return m_wrapped->scale();
}

QSizeF Screen::physicalSize() const
{
    return m_wrapped->physicalSize();
}

qtmir::FormFactor Screen::formFactor() const
{
    return m_wrapped->formFactor();
}

qtmir::OutputTypes Screen::outputType() const
{
    return m_wrapped->outputType();
}

MirPowerMode Screen::powerMode() const
{
    return m_wrapped->powerMode();
}

Qt::ScreenOrientation Screen::orientation() const
{
    return m_wrapped->orientation();
}

QPoint Screen::position() const
{
    return m_wrapped->position();
}

QQmlListProperty<qtmir::ScreenMode> Screen::availableModes()
{
    return m_wrapped->availableModes();
}

uint Screen::currentModeIndex() const
{
    return m_wrapped->currentModeIndex();
}

bool Screen::isActive() const
{
    return m_wrapped->isActive();
}

qtmir::ScreenConfiguration *Screen::beginConfiguration() const
{
    return m_wrapped->beginConfiguration();
}

bool Screen::applyConfiguration(qtmir::ScreenConfiguration *configuration)
{
    return m_wrapped->applyConfiguration(configuration);
}

void Screen::activate()
{
    setActive(true);
}

void Screen::setActive(bool active)
{
    m_wrapped->setActive(active);
}

QScreen *Screen::qscreen() const
{
    return m_wrapped->qscreen();
}
