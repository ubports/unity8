/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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

#include "Window.h"

// unity-api
#include <unity/shell/application/MirSurfaceInterface.h>

#include <QQmlEngine>
#include <QTextStream>

namespace unityapi = unity::shell::application;

Q_LOGGING_CATEGORY(UNITY_WINDOW, "unity.window", QtWarningMsg)

#define DEBUG_MSG qCDebug(UNITY_WINDOW).nospace() << qPrintable(toString()) << "::" << __func__

Window::Window(int id, QObject *parent)
    : QObject(parent)
    , m_id(id)
{
    DEBUG_MSG << "()";
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Window::~Window()
{
    DEBUG_MSG << "()";
}

QPoint Window::position() const
{
    return m_position;
}

QPoint Window::requestedPosition() const
{
    return m_requestedPosition;
}

void Window::setRequestedPosition(const QPoint &value)
{
    m_positionRequested = true;
    if (value != m_requestedPosition) {
        m_requestedPosition = value;
        Q_EMIT requestedPositionChanged(m_requestedPosition);
        if (m_surface) {
            m_surface->setRequestedPosition(value);
        } else {
            // fake-miral: always comply
            m_position = m_requestedPosition;
            Q_EMIT positionChanged(m_position);
        }
    }
}

bool Window::allowClientResize() const
{
    return m_allowClientResize;
}

void Window::setAllowClientResize(bool value)
{
    if (value != m_allowClientResize) {
        DEBUG_MSG << "("<<value<<")";
        m_allowClientResize = value;
        if (m_surface) {
            m_surface->setAllowClientResize(value);
        }
        Q_EMIT allowClientResizeChanged(m_allowClientResize);
    }
}

Mir::State Window::state() const
{
    return m_state;
}

bool Window::focused() const
{
    return m_focused;
}

bool Window::confinesMousePointer() const
{
    if (m_surface) {
        return m_surface->confinesMousePointer();
    } else {
        return false;
    }
}

int Window::id() const
{
    return m_id;
}

unityapi::MirSurfaceInterface* Window::surface() const
{
    return m_surface;
}

void Window::requestState(Mir::State state)
{
    m_stateRequested = true;
    if (m_surface) {
        m_surface->requestState(state);
    } else if (m_state != state) {
        m_state = state;
        Q_EMIT stateChanged(m_state);
    }
}

void Window::close()
{
    if (m_surface) {
        m_surface->close();
    } else {
        Q_EMIT closeRequested();
    }
}

void Window::activate()
{
    DEBUG_MSG << "()";
    if (m_surface) {
        m_surface->activate();
    } else {
        Q_EMIT emptyWindowActivated();
    }
}

void Window::setSurface(unityapi::MirSurfaceInterface *surface)
{
    DEBUG_MSG << "(" << surface << ")";
    if (m_surface) {
        disconnect(m_surface, 0, this, 0);
    }

    m_surface = surface;

    if (m_surface) {
        connect(surface, &unityapi::MirSurfaceInterface::focusRequested, this, [this]() {
            Q_EMIT focusRequested();
        });

        connect(surface, &unityapi::MirSurfaceInterface::closeRequested, this, &Window::closeRequested);

        connect(surface, &unityapi::MirSurfaceInterface::positionChanged, this, [this]() {
            updatePosition();
        });

        connect(surface, &unityapi::MirSurfaceInterface::stateChanged, this, [this]() {
            updateState();
        });

        connect(surface, &unityapi::MirSurfaceInterface::focusedChanged, this, [this]() {
            updateFocused();
        });

        connect(surface, &unityapi::MirSurfaceInterface::allowClientResizeChanged, this, [this]() {
            if (m_surface->allowClientResize() != m_allowClientResize) {
                m_allowClientResize = m_surface->allowClientResize();
                Q_EMIT allowClientResizeChanged(m_allowClientResize);
            }
        });

        connect(surface, &unityapi::MirSurfaceInterface::liveChanged, this, &Window::liveChanged);

        connect(surface, &QObject::destroyed, this, [this]() {
            setSurface(nullptr);
        });

        // bring it up to speed
        if (m_positionRequested) {
            m_surface->setRequestedPosition(m_requestedPosition);
        }
        if (m_stateRequested && m_surface->state() == Mir::RestoredState) {
            m_surface->requestState(m_state);
        }
        m_surface->setAllowClientResize(m_allowClientResize);

        // and sync with surface
        updatePosition();
        updateState();
        updateFocused();
    }

    Q_EMIT surfaceChanged(surface);
}

void Window::updatePosition()
{
    if (m_surface->position() != m_position) {
        m_position = m_surface->position();
        Q_EMIT positionChanged(m_position);
    }
}

void Window::updateState()
{
    if (m_surface->state() != m_state) {
        m_state = m_surface->state();
        Q_EMIT stateChanged(m_state);
    }
}

void Window::updateFocused()
{
    if (m_surface->focused() != m_focused) {
        m_focused = m_surface->focused();
        Q_EMIT focusedChanged(m_focused);
    }
}

void Window::setFocused(bool value)
{
    if (value != m_focused) {
        DEBUG_MSG << "(" << value << ")";
        m_focused = value;
        Q_EMIT focusedChanged(m_focused);
        // when we have a surface we get focus changes from updateFocused() instead
        Q_ASSERT(!m_surface);
    }
}

QString Window::toString() const
{
    QString result;
    {
        QTextStream stream(&result);
        stream << "Window["<<(void*)this<<", id="<<id()<<", ";
        if (surface()) {
            stream << "MirSurface["<<(void*)surface()<<",\""<<surface()->name()<<"\"]";
        } else {
            stream << "null";
        }
        stream << "]";
    }
    return result;
}

QDebug operator<<(QDebug dbg, const Window *window)
{
    QDebugStateSaver saver(dbg);
    dbg.nospace();

    if (window) {
        dbg << qPrintable(window->toString());
    } else {
        dbg << (void*)(window);
    }

    return dbg;
}
