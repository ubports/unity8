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

#include "InputMethodManager.h"
#include <QDebug>

#include <lomiri/shell/application/MirSurfaceInterface.h>

// local
#include "Window.h"

Q_LOGGING_CATEGORY(INPUTMETHODMANAGER, "InputMethodManager", QtInfoMsg)
#define DEBUG_MSG qCDebug(INPUTMETHODMANAGER).nospace().noquote() << __func__

namespace lomiriapi = lomiri::shell::application;

InputMethodManager *InputMethodManager::instance()
{
    static InputMethodManager* inputMethod(new InputMethodManager());
    return inputMethod;
}

InputMethodManager::InputMethodManager()
{
}

void InputMethodManager::setWindow(Window* window)
{
    if (window == m_inputMethodWindow) {
        return;
    }

    DEBUG_MSG << "(" << window << ")";

    m_inputMethodWindow = window;
    Q_EMIT surfaceChanged(surface());
}

lomiriapi::MirSurfaceInterface* InputMethodManager::surface() const
{
    return m_inputMethodWindow ? m_inputMethodWindow->surface() : nullptr;
}
