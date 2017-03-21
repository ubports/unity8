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

#ifndef UNITY_WINDOW_H
#define UNITY_WINDOW_H

#include <QLoggingCategory>
#include <QObject>
#include <QPoint>

// Unity API
#include <unity/shell/application/Mir.h>

#include "WindowManagerGlobal.h"

namespace unity {
    namespace shell {
        namespace application {
            class MirSurfaceInterface;
        }
    }
}

Q_DECLARE_LOGGING_CATEGORY(UNITY_WINDOW)

/**
   @brief A slightly higher concept than MirSurface

   A Window exists before its MirSurface gets created (for splashscreen purposes)
   and might also hang around after the backing surface is gone (In case the application
   was killed to free up memory, as it should still remain in the window list since the user
   did not explicitly close it).
 */
class WINDOWMANAGERQML_EXPORT Window : public QObject
{
    Q_OBJECT

    /**
     * @brief Position of the current surface buffer, in pixels.
     */
    Q_PROPERTY(QPoint position READ position NOTIFY positionChanged)

    /**
     * @brief Requested position of the current surface buffer, in pixels.
     */
    Q_PROPERTY(QPoint requestedPosition READ requestedPosition WRITE setRequestedPosition NOTIFY requestedPositionChanged)

    /**
     * @brief State of the surface
     */
    Q_PROPERTY(Mir::State state READ state NOTIFY stateChanged)

    /**
     * @brief Whether the surface is focused
     *
     * It will be true if this surface is MirFocusControllerInterface::focusedSurface
     */
    Q_PROPERTY(bool focused READ focused NOTIFY focusedChanged)

    /**
     * @brief Whether the surface wants to confine the mouse pointer within its boundaries
     *
     * If true, the surface doesn't want the mouse pointer to leave its boundaries while it's focused.
     */
    Q_PROPERTY(bool confinesMousePointer READ confinesMousePointer NOTIFY confinesMousePointerChanged)

    /**
     * @brief A unique identifier for this window.
     * Useful for telling windows apart in a list model as they get moved around
     */
    Q_PROPERTY(int id READ id CONSTANT)

    /**
     * @brief Surface backing up this window
     * It might be null if a surface hasn't been created yet (application is starting up) or if
     * the corresponding application has been killed (but can still get restarted to continue from
     * where it left)
     */
    Q_PROPERTY(unity::shell::application::MirSurfaceInterface* surface READ surface NOTIFY surfaceChanged)

    /**
     * @brief Whether to comply to resize requests coming from the client side
     *
     * It's true by default
     */
    Q_PROPERTY(bool allowClientResize READ allowClientResize WRITE setAllowClientResize NOTIFY allowClientResizeChanged)

public:
    Window(int id, QObject *parent = nullptr);
    virtual ~Window();
    QPoint position() const;
    QPoint requestedPosition() const;
    void setRequestedPosition(const QPoint &);
    Mir::State state() const;
    bool focused() const;
    bool confinesMousePointer() const;
    int id() const;
    unity::shell::application::MirSurfaceInterface* surface() const;

    void setSurface(unity::shell::application::MirSurfaceInterface *surface);
    void setFocused(bool value);

    bool allowClientResize() const;
    void setAllowClientResize(bool);

    QString toString() const;

public Q_SLOTS:
    /**
     * @brief Requests a change to the specified state
     */
    void requestState(Mir::State state);

    /**
     * @brief Sends a close request
     *
     */
    void close();

    /**
     * @brief Focuses and raises the window
     */
    void activate();

Q_SIGNALS:
    void closeRequested();
    void emptyWindowActivated();

    void positionChanged(QPoint position);
    void requestedPositionChanged(QPoint position);
    void stateChanged(Mir::State value);
    void focusedChanged(bool value);
    void confinesMousePointerChanged(bool value);
    void surfaceChanged(unity::shell::application::MirSurfaceInterface *surface);
    void allowClientResizeChanged(bool value);
    void liveChanged(bool value);

    /**
     * @brief Emitted when focus for this window is requested by an external party
     */
    void focusRequested();

private:
    void updatePosition();
    void updateState();
    void updateFocused();

    QPoint m_position;
    QPoint m_requestedPosition;
    bool m_positionRequested{false};
    bool m_focused{false};
    int m_id;
    Mir::State m_state{Mir::RestoredState};
    bool m_stateRequested{false};
    unity::shell::application::MirSurfaceInterface *m_surface{nullptr};

    bool m_allowClientResize{true};
};

QDebug operator<<(QDebug dbg, const Window *window);

Q_DECLARE_METATYPE(Window*)
#endif // UNITY_WINDOW_H
