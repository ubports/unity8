/*
 * Copyright (C) 2019 UBports Foundation.
 * Author(s) Marius Gripsgard <marius@ubports.com>
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

#pragma once

#include <QLoggingCategory>
#include <QObject>

#include "WindowManagerGlobal.h"

Q_DECLARE_LOGGING_CATEGORY(INPUTMETHODMANAGER)

class Window;

namespace lomiri {
    namespace shell {
        namespace application {
            class MirSurfaceInterface;
        }
    }
}

class WINDOWMANAGERQML_EXPORT InputMethodManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(lomiri::shell::application::MirSurfaceInterface* surface READ surface NOTIFY surfaceChanged)

public:
    InputMethodManager();
    static InputMethodManager* instance();

    void setWindow(Window* window);

Q_SIGNALS:
    void surfaceChanged(lomiri::shell::application::MirSurfaceInterface* inputMethodSurface);

private:
    lomiri::shell::application::MirSurfaceInterface* surface() const;

     Window* m_inputMethodWindow{nullptr};
};
