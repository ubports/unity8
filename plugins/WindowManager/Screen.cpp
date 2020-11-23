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

Screen::Screen(QObject *parent)
    : QObject(parent)
{
}

void Screen::connectToScreen(qtmir::Screen *screen)
{
    m_wrapped = screen;
    connect(screen, &qtmir::Screen::usedChanged, this, &Screen::usedChanged);
    connect(screen, &qtmir::Screen::nameChanged, this, &Screen::nameChanged);
    connect(screen, &qtmir::Screen::outputTypeChanged, this, &Screen::outputTypeChanged);
    connect(screen, &qtmir::Screen::outputTypeChanged, this, &Screen::outputTypeNameChanged);
    connect(screen, &qtmir::Screen::scaleChanged, this, &Screen::scaleChanged);
    connect(screen, &qtmir::Screen::formFactorChanged, this, &Screen::formFactorChanged);
    connect(screen, &qtmir::Screen::physicalSizeChanged, this, &Screen::physicalSizeChanged);
    connect(screen, &qtmir::Screen::positionChanged, this, &Screen::positionChanged);
    connect(screen, &qtmir::Screen::activeChanged, this, &Screen::activeChanged);
    connect(screen, &qtmir::Screen::currentModeIndexChanged, this, &Screen::currentModeIndexChanged);
    connect(screen, &qtmir::Screen::availableModesChanged, this, &Screen::availableModesChanged);
}

void Screen::connectToScreen(Screen *screen)
{
    connectToScreen(screen->wrapped());
    connect(screen, &Screen::currentWorkspaceChanged, this, &Screen::currentWorkspaceChanged);
}

void Screen::setCurrentWorkspace2(Workspace *workspace)
{
    // Make sure we use the correct concrete class. Don't want to use a Proxy.
    workspace->setCurrentOn(this);
}

bool Screen::used() const
{
    if (!m_wrapped) return false;
    return m_wrapped->used();
}

QString Screen::name() const
{
    if (!m_wrapped) return QString();
    return m_wrapped->name();
}

float Screen::scale() const
{
    if (!m_wrapped) return 1.0;
    return m_wrapped->scale();
}

QSizeF Screen::physicalSize() const
{
    if (!m_wrapped) return QSizeF();
    return m_wrapped->physicalSize();
}

qtmir::FormFactor Screen::formFactor() const
{
    if (!m_wrapped) return qtmir::FormFactorUnknown;
    return m_wrapped->formFactor();
}

qtmir::OutputTypes Screen::outputType() const
{
    if (!m_wrapped) return qtmir::Unknown;
    return m_wrapped->outputType();
}

MirPowerMode Screen::powerMode() const
{
    if (!m_wrapped) return mir_power_mode_on;
    return m_wrapped->powerMode();
}

Qt::ScreenOrientation Screen::orientation() const
{
    if (!m_wrapped) return Qt::PrimaryOrientation;
    return m_wrapped->orientation();
}

QPoint Screen::position() const
{
    if (!m_wrapped) return QPoint();
    return m_wrapped->position();
}

QQmlListProperty<qtmir::ScreenMode> Screen::availableModes()
{
    if (!m_wrapped) return QQmlListProperty<qtmir::ScreenMode>();
    return m_wrapped->availableModes();
}

uint Screen::currentModeIndex() const
{
    if (!m_wrapped) return -1;
    return m_wrapped->currentModeIndex();
}

bool Screen::isActive() const
{
    if (!m_wrapped) return false;
    return m_wrapped->isActive();
}

void Screen::activate()
{
    setActive(true);
}

void Screen::setActive(bool active)
{
    if (!m_wrapped) return;
    m_wrapped->setActive(active);
}

QScreen *Screen::qscreen() const
{
    if (!m_wrapped) return nullptr;
    return m_wrapped->qscreen();
}

ScreenConfig *Screen::beginConfiguration() const
{
    if (!m_wrapped) return nullptr;
    return new ScreenConfig(m_wrapped->beginConfiguration());
}

bool Screen::applyConfiguration(ScreenConfig *configuration)
{
    if (!m_wrapped) return false;
    return m_wrapped->applyConfiguration(configuration->m_config);
}

QString Screen::outputTypeName() const
{
    switch (m_wrapped->outputType()) {
    case qtmir::Unknown:
        return tr("Unknown");
    case qtmir::VGA:
        return tr("VGA");
    case qtmir::DVII:
    case qtmir::DVID:
    case qtmir::DVIA:
        return tr("DVI");
    case qtmir::Composite:
        return tr("Composite");
    case qtmir::SVideo:
        return tr("S-Video");
    case qtmir::LVDS:
    case qtmir::NinePinDIN:
    case qtmir::EDP:
        return tr("Internal");
    case qtmir::Component:
        return tr("Component");
    case qtmir::DisplayPort:
        return tr("DisplayPort");
    case qtmir::HDMIA:
    case qtmir::HDMIB:
        return tr("HDMI");
    case qtmir::TV:
        return tr("TV");
    }
    return QString();
}

bool Screen::isSameAs(Screen *screen) const
{
    if (!screen) return false;
    if (screen == this) return true;
    return wrapped() == screen->wrapped();
}

void Screen::sync(Screen *proxy)
{
    if (!proxy) return;
    workspaces()->sync(proxy->workspaces());
}

ConcreteScreen::ConcreteScreen(qtmir::Screen* wrapped)
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
    connect(this, &ConcreteScreen::activeChanged, this, [this](bool active) {
        if (active && m_currentWorspace) {
            m_currentWorspace->activate();
        }
    });
}

void ConcreteScreen::resetCurrentWorkspace()
{
    auto newCurrent = m_workspaces->rowCount() > 0 ? m_workspaces->get(0) : nullptr;
    if (m_currentWorspace != newCurrent) {
        m_currentWorspace = newCurrent;
        Q_EMIT currentWorkspaceChanged(newCurrent);
    }
}


WorkspaceModel *ConcreteScreen::workspaces() const
{
    return m_workspaces.data();
}

Workspace *ConcreteScreen::currentWorkspace() const
{
    return m_currentWorspace.data();
}

void ConcreteScreen::setCurrentWorkspace(Workspace *workspace)
{
    if (m_currentWorspace != workspace) {
        m_currentWorspace = workspace;
        Q_EMIT currentWorkspaceChanged(workspace);
    }
}

ProxyScreen::ProxyScreen(Screen *const screen, ProxyScreens* screens)
    : m_workspaces(new ProxyWorkspaceModel(screen->workspaces(), this))
    , m_original(screen)
    , m_screens(screens)
{
    connectToScreen(screen);

    auto updateCurrentWorkspaceFn = [this](Workspace* realWorkspace) {
        Q_FOREACH(Workspace* workspace, m_workspaces->list()) {
            auto p = qobject_cast<ProxyWorkspace*>(workspace);
            if (p && p->proxyObject() == realWorkspace) {
               if (m_currentWorspace != p) {
                   m_currentWorspace = p;
                   Q_EMIT currentWorkspaceChanged(p);
               }
            }
        }
    };
    connect(screen, &Screen::currentWorkspaceChanged, this, updateCurrentWorkspaceFn);
    updateCurrentWorkspaceFn(screen->currentWorkspace());
}

WorkspaceModel *ProxyScreen::workspaces() const
{
    return m_workspaces.data();
}

Workspace *ProxyScreen::currentWorkspace() const
{
    return m_currentWorspace.data();
}

void ProxyScreen::setCurrentWorkspace(Workspace *workspace)
{
    auto p = qobject_cast<ProxyWorkspace*>(workspace);
    if (p) {
        m_original->setCurrentWorkspace(p->proxyObject());
    }
}

bool ProxyScreen::isSyncing() const
{
    return m_screens->isSyncing();
}

ScreenConfig::ScreenConfig(qtmir::ScreenConfiguration *config)
    : m_config(config)
{
}

ScreenConfig::~ScreenConfig()
{
    delete m_config;
}
