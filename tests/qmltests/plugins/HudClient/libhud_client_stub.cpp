/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#include "libhud_client_stub.h"

HudClientQuery *HudClientStub::m_query;
guint HudClientStub::m_querySignalToolbarUpdated;
int HudClientStub::m_lastExecutedToolbarItem;
QString HudClientStub::m_lastSetQuery;
int HudClientStub::m_lastExecutedCommandRow;
int HudClientStub::m_lastExecutedParametrizedCommandRow;
bool HudClientStub::m_lastParametrizedCommandCommited;
QVariantMap HudClientStub::m_activatedActions;
bool HudClientStub::m_helpToolbarItemEnabled = true;

int HudClientStub::lastExecutedToolbarItem() const
{
    return m_lastExecutedToolbarItem;
}

QString HudClientStub::lastSetQuery() const
{
    return m_lastSetQuery;
}

int HudClientStub::lastExecutedCommandRow() const
{
    return m_lastExecutedCommandRow;
}

int HudClientStub::lastExecutedParametrizedCommandRow() const
{
    return m_lastExecutedParametrizedCommandRow;
}

bool HudClientStub::lastParametrizedCommandCommited() const
{
    return m_lastParametrizedCommandCommited;
}

QVariantMap HudClientStub::activatedActions() const
{
    return m_activatedActions;
}

void HudClientStub::reset()
{
    m_lastExecutedToolbarItem = -1;
    m_lastSetQuery.clear();
    m_lastExecutedCommandRow = -1;
    m_lastExecutedParametrizedCommandRow = -1;
    m_lastParametrizedCommandCommited = false;
    m_activatedActions.clear();
}

int HudClientStub::fullScreenToolbarItemValue() const
{
    return HUD_CLIENT_QUERY_TOOLBAR_FULLSCREEN;
}

int HudClientStub::helpToolbarItemValue() const
{
    return HUD_CLIENT_QUERY_TOOLBAR_HELP;
}

int HudClientStub::preferencesToolbarItemValue() const
{
    return HUD_CLIENT_QUERY_TOOLBAR_PREFERENCES;
}

int HudClientStub::undoToolbarItemValue() const
{
    return HUD_CLIENT_QUERY_TOOLBAR_UNDO;
}

void HudClientStub::setHelpToolbarItemEnabled(bool enabled) const
{
    m_helpToolbarItemEnabled = enabled;
    g_signal_emit(G_OBJECT(m_query), m_querySignalToolbarUpdated, 0);
}
