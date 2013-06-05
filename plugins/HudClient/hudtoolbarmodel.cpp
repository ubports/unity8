/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "hudtoolbarmodel.h"

#include "hudclient.h"

static const int ActionRole = Qt::UserRole;
static const int EnabledRole = Qt::UserRole + 1;

static QString iconForAction(int action)
{
    switch (action) {
        case HUD_CLIENT_QUERY_TOOLBAR_UNDO:
            return "graphics/undo.png";
        case HUD_CLIENT_QUERY_TOOLBAR_HELP:
            return "graphics/help.png";
        case HUD_CLIENT_QUERY_TOOLBAR_FULLSCREEN:
            return "graphics/view-fullscreen.png";
        case HUD_CLIENT_QUERY_TOOLBAR_PREFERENCES:
            return "graphics/settings.png";
    }
    return QString();
}

HudToolBarModel::HudToolBarModel(HudClientQuery *query)
 : m_query(query)
{
    m_actions << HUD_CLIENT_QUERY_TOOLBAR_UNDO
              << HUD_CLIENT_QUERY_TOOLBAR_HELP
              << HUD_CLIENT_QUERY_TOOLBAR_FULLSCREEN
              << HUD_CLIENT_QUERY_TOOLBAR_PREFERENCES;
}

HudToolBarModel::~HudToolBarModel()
{
}

int HudToolBarModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_actions.count();
}

QVariant HudToolBarModel::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if (row >= m_actions.count())
        return QVariant();

    const HudClientQueryToolbarItems action = m_actions[row];

    switch (role) {
        case Qt::DecorationRole:
                return iconForAction(action);
            break;

        case ActionRole:
                return action;
            break;

        case EnabledRole:
                return hud_client_query_toolbar_item_active(m_query, action);
            break;
    }
    return QVariant();
}

QHash<int,QByteArray> HudToolBarModel::roleNames() const
{
    static QHash<int,QByteArray> roles;
    if (roles.isEmpty()) {
        roles[Qt::DecorationRole] = "iconPath";
        roles[ActionRole] = "action";
        roles[EnabledRole] = "enabled";
    }
    return roles;
}

void HudToolBarModel::updatedByBackend()
{
    Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0), QVector<int>() << EnabledRole);
}
