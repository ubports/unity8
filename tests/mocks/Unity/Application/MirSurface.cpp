/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

#include "MirSurface.h"

#include <QDebug>
#include <QQmlEngine>

#define MIRSURFACE_DEBUG 0

#if MIRSURFACE_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "MirSurface[" << (void*)this << "," << m_name << "]::" << __func__  << " " << params

const char *stateToStr(Mir::State state)
{
    switch(state) {
    case Mir::UnknownState:
        return "unknown";
    case Mir::RestoredState:
        return "restored";
    case Mir::MinimizedState:
        return "minimized";
    case Mir::MaximizedState:
        return "maximized";
    case Mir::VertMaximizedState:
        return "vert-maximized";
    case Mir::FullscreenState:
        return "fullscreen";
    case Mir::HorizMaximizedState:
        return "horiz-maximized";
    case Mir::HiddenState:
        return "hidden";
    default:
        return "???";
    };
}

#else
#define DEBUG_MSG(params) ((void)0)
#endif

using namespace unity::shell::application;

MirFocusController *MirFocusController::m_instance = nullptr;

MirSurface::MirSurface(const QString& name,
        Mir::Type type,
        Mir::State state,
        const QUrl& screenshot,
        const QUrl &qmlFilePath)
    : unity::shell::application::MirSurfaceInterface(nullptr)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_orientationAngle(Mir::Angle0)
    , m_screenshotUrl(screenshot)
    , m_qmlFilePath(qmlFilePath)
    , m_live(true)
    , m_visible(true)
    , m_activeFocus(false)
    , m_width(-1)
    , m_height(-1)
    , m_slowToResize(false)
    , m_shellChrome(Mir::NormalChrome)
{
    DEBUG_MSG("");

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    m_delayedResizeTimer.setInterval(600);
    m_delayedResizeTimer.setSingleShot(true);
    connect(&m_delayedResizeTimer, &QTimer::timeout, this, &MirSurface::applyDelayedResize);

    m_zombieTimer.setInterval(100);
    m_zombieTimer.setSingleShot(true);
    connect(&m_zombieTimer, &QTimer::timeout, this, [this](){ this->setLive(false); });

    updateInputBoundsAfterResize();
}

MirSurface::~MirSurface()
{
    DEBUG_MSG("");

    // controller instance might have been already destroyed by QQmlEngine destructor
    auto controller = MirFocusController::instance();
    if (controller && controller->focusedSurface() == this) {
        controller->clear();
    }
}

QString MirSurface::name() const
{
    return m_name;
}

QString MirSurface::persistentId() const
{
    return m_name+"Id";
}

Mir::Type MirSurface::type() const
{
    return m_type;
}

Mir::State MirSurface::state() const
{
    return m_state;
}

void MirSurface::setState(Mir::State state)
{
    if (state == m_state)
        return;

    DEBUG_MSG(stateToStr(state));
    m_state = state;
    Q_EMIT stateChanged(state);
}

bool MirSurface::live() const
{
    return m_live;
}

bool MirSurface::visible() const
{
    return m_visible;
}

void MirSurface::setLive(bool live)
{
    if (live == m_live)
        return;

    DEBUG_MSG(live);
    m_live = live;
    Q_EMIT liveChanged(live);

    if (!m_live && m_views.count() == 0) {
        deleteLater();
    }
}

QUrl MirSurface::qmlFilePath() const
{
    return m_qmlFilePath;
}

QUrl MirSurface::screenshotUrl() const
{
    return m_screenshotUrl;
}

void MirSurface::setScreenshotUrl(QUrl screenshotUrl)
{
    if (screenshotUrl == m_screenshotUrl)
        return;

    m_screenshotUrl = screenshotUrl;
    Q_EMIT screenshotUrlChanged(screenshotUrl);
}

Mir::OrientationAngle MirSurface::orientationAngle() const
{
    return m_orientationAngle;
}

void MirSurface::setOrientationAngle(Mir::OrientationAngle angle)
{
    if (angle == m_orientationAngle)
        return;

    m_orientationAngle = angle;
    Q_EMIT orientationAngleChanged(angle);
}

void MirSurface::setKeymap(const QString &value)
{
    if (value != m_keymap) {
        DEBUG_MSG(value);
        m_keymap = value;
        Q_EMIT keymapChanged(m_keymap);
    }
}

QString MirSurface::keymap() const
{
    return m_keymap;
}

Mir::ShellChrome MirSurface::shellChrome() const
{
    return m_shellChrome;
}

void MirSurface::setShellChrome(Mir::ShellChrome shellChrome)
{
    if (shellChrome == m_shellChrome)
        return;

    DEBUG_MSG(shellChrome);
    m_shellChrome = shellChrome;
    Q_EMIT shellChromeChanged(shellChrome);
}

void MirSurface::registerView(qintptr viewId)
{
    m_views.insert(viewId, MirSurface::View{false});
    DEBUG_MSG(viewId << " after=" << m_views.count());
}

void MirSurface::unregisterView(qintptr viewId)
{
    m_views.remove(viewId);
    DEBUG_MSG(viewId << " after=" << m_views.count() << " live=" << m_live);
    if (!m_live && m_views.count() == 0) {
        deleteLater();
    }
    updateVisibility();
}

void MirSurface::setViewVisibility(qintptr viewId, bool visible)
{
    if (!m_views.contains(viewId)) return;

    m_views[viewId].visible = visible;
    updateVisibility();
}

void MirSurface::updateVisibility()
{
    bool newVisible = false;
    QHashIterator<qintptr, View> i(m_views);
    while (i.hasNext()) {
        i.next();
        newVisible |= i.value().visible;
    }

    if (newVisible != visible()) {
//        qDebug().nospace() << "MirSurface[" << name() << "]::updateVisibility(" << newVisible << ")";

        m_visible = newVisible;
        Q_EMIT visibleChanged(m_visible);
    }
}

bool MirSurface::activeFocus() const
{
    return m_activeFocus;
}

void MirSurface::setActiveFocus(bool value)
{
    if (m_activeFocus == value)
        return;

    m_activeFocus = value;

    Q_EMIT activeFocusChanged(value);
}

int MirSurface::width() const
{
    return m_width;
}

int MirSurface::height() const
{
    return m_height;
}

void MirSurface::resize(int width, int height)
{
    if (m_slowToResize) {
        if (!m_delayedResizeTimer.isActive()) {
            m_delayedResize.setWidth(width);
            m_delayedResize.setHeight(height);
            m_delayedResizeTimer.start();
        } else {
            m_pendingResize.setWidth(width);
            m_pendingResize.setHeight(height);
        }
    } else {
        doResize(width, height);
    }
}

void MirSurface::applyDelayedResize()
{
    doResize(m_delayedResize.width(), m_delayedResize.height());
    m_delayedResize.setWidth(-1);
    m_delayedResize.setHeight(-1);

    if (m_pendingResize.isValid()) {
        QSize size = m_pendingResize;
        m_pendingResize.setWidth(-1);
        m_pendingResize.setHeight(-1);
        resize(size.width(), size.height());
    }
}

void MirSurface::doResize(int width, int height)
{
    bool changed = false;

    if (width != m_width) {
        m_width = width;
        Q_EMIT widthChanged();
        changed = true;
    }

    if (m_height != height) {
        m_height = height;
        Q_EMIT heightChanged();
        changed = true;
    }

    if (changed) {
        Q_EMIT sizeChanged(QSize(width, height));
    }

    updateInputBoundsAfterResize();
}

void MirSurface::updateInputBoundsAfterResize()
{
    setInputBounds(QRect(0, 0, m_width, m_height));
}

bool MirSurface::isSlowToResize() const
{
    return m_slowToResize;
}

void MirSurface::setSlowToResize(bool value)
{
    if (m_slowToResize != value) {
        DEBUG_MSG(value);
        m_slowToResize = value;
        Q_EMIT slowToResizeChanged();
        if (!m_slowToResize && m_delayedResizeTimer.isActive()) {
            m_delayedResizeTimer.stop();
            applyDelayedResize();
        }
    }
}

void MirSurface::setMinimumWidth(int value)
{
    if (value != m_minimumWidth) {
        m_minimumWidth = value;
        Q_EMIT minimumWidthChanged(m_minimumWidth);
    }
}

void MirSurface::setMaximumWidth(int value)
{
    if (value != m_maximumWidth) {
        m_maximumWidth = value;
        Q_EMIT maximumWidthChanged(m_maximumWidth);
    }
}

void MirSurface::setMinimumHeight(int value)
{
    if (value != m_minimumHeight) {
        m_minimumHeight = value;
        Q_EMIT minimumHeightChanged(m_minimumHeight);
    }
}

void MirSurface::setMaximumHeight(int value)
{
    if (value != m_maximumHeight) {
        m_maximumHeight = value;
        Q_EMIT maximumHeightChanged(m_maximumHeight);
    }
}

void MirSurface::setWidthIncrement(int value)
{
    if (value != m_widthIncrement) {
        m_widthIncrement = value;
        Q_EMIT widthIncrementChanged(m_widthIncrement);
    }
}

void MirSurface::setHeightIncrement(int value)
{
    if (value != m_heightIncrement) {
        m_heightIncrement = value;
        Q_EMIT heightIncrementChanged(m_heightIncrement);
    }
}

void MirSurface::raise()
{
    Q_EMIT raiseRequested();
}

void MirSurface::close()
{
    DEBUG_MSG("");
    if (!m_zombieTimer.isActive()) {
        m_zombieTimer.start();
        Q_EMIT closeRequested();
    }
}

void MirSurface::requestFocus()
{
    DEBUG_MSG("");
    Q_EMIT focusRequested();
}

void MirSurface::setFocused(bool value)
{
    DEBUG_MSG(value);

    auto controller = MirFocusController::instance();
    // controller instance might have been already destroyed by QQmlEngine destructor
    if (!controller) {
        return;
    }

    if (value) {
        controller->setFocusedSurface(this);
    } else if (controller->focusedSurface() == this) {
        controller->setFocusedSurface(nullptr);
    }
}

bool MirSurface::focused() const
{
    auto controller = MirFocusController::instance();

    // controller instance might have been already destroyed by QQmlEngine destructor
    return controller ? controller->focusedSurface() == this : false;
}

QRect MirSurface::inputBounds() const
{
    return m_inputBounds;
}

void MirSurface::setInputBounds(const QRect &boundsRect)
{
    if (boundsRect != m_inputBounds) {
        m_inputBounds = boundsRect;
        Q_EMIT inputBoundsChanged(m_inputBounds);
    }
}
#if MIRSURFACE_DEBUG
#undef DEBUG_MSG
#define DEBUG_MSG(params) qDebug().nospace() << "MirFocusController::" << __func__  << " " << params
#endif

void MirFocusController::setFocusedSurface(MirSurfaceInterface *surface)
{
    if (m_focusedSurface == surface) {
        return;
    }
    DEBUG_MSG("MirSurface[" << (void*)surface << "," << (surface?surface->name():"") << "]");

    m_previouslyFocusedSurface = m_focusedSurface;
    m_focusedSurface = surface;

    if (m_previouslyFocusedSurface != m_focusedSurface) {
        Q_EMIT focusedSurfaceChanged();
    }

    if (m_previouslyFocusedSurface) {
        Q_EMIT m_previouslyFocusedSurface->focusedChanged(false);
    }

    if (m_focusedSurface) {
        Q_EMIT m_focusedSurface->focusedChanged(true);
        m_focusedSurface->raise();
    }
}

MirFocusController* MirFocusController::instance()
{
    return m_instance;
}

MirFocusController::MirFocusController()
{
    DEBUG_MSG("");
    Q_ASSERT(m_instance == nullptr);
    m_instance = this;
}

MirFocusController::~MirFocusController()
{
    Q_ASSERT(m_instance == this);
    m_instance = nullptr;
}

void MirFocusController::clear()
{
    m_focusedSurface = m_previouslyFocusedSurface = nullptr;
    Q_EMIT focusedSurfaceChanged();
}
