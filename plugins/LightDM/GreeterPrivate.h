/*
 * Copyright (C) 2015-2017 Canonical, Ltd.
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

#pragma once

#include "PromptsModel.h"
#include <QObject>

namespace QLightDM {
    class Greeter;
}

class GreeterPrivate
{
public:
    explicit GreeterPrivate(Greeter *parent);

    QLightDM::Greeter *m_greeter;
    bool m_active;
    PromptsModel prompts;
    PromptsModel leftovers; // prompts to show during next auth for same user
    bool responded;
    bool everResponded;
    QString cachedAuthUser;

protected:
    Greeter * const q_ptr;

private:
    Q_DECLARE_PUBLIC(Greeter)
};
