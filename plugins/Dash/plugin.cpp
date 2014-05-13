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
 *
 */

#include "plugin.h"

#include "horizontaljournal.h"
#include "listviewwithpageheader.h"
#include "organicgrid.h"
#include "verticaljournal.h"

#include <QAbstractItemModel>

void DashPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Dash"));
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<HorizontalJournal>(uri, 0, 1, "HorizontalJournal");
    qmlRegisterType<ListViewWithPageHeader>(uri, 0, 1, "ListViewWithPageHeader");
    qmlRegisterType<OrganicGrid>(uri, 0, 1, "OrganicGrid");
    qmlRegisterType<VerticalJournal>(uri, 0, 1, "VerticalJournal");
}
