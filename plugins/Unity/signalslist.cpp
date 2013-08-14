/*
  * Copyright (C) 2013 Canonical, Ltd.
  *
  * Authors:
  *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

#include "signalslist.h"

void SignalsList::append(const sigc::connection &c)
{
    m_signals.append(c);
}

void SignalsList::disconnectAll()
{
    Q_FOREACH(auto sig, m_signals) {
        sig.disconnect();
    }
    m_signals.clear();
}

SignalsList& SignalsList::operator<<(const sigc::connection &c)
{
    append(c);
    return *this;
}
