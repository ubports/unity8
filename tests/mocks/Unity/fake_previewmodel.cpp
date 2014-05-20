/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *  Michal Hruby <michal.hruby@canonical.com>
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

// self
#include "fake_previewmodel.h"

// local
#include "fake_previewwidgetmodel.h"

// Qt
#include <QDebug>

PreviewModel::PreviewModel(QObject* parent)
 : unity::shell::scopes::PreviewModelInterface(parent)
{
    // we have one column by default
    PreviewWidgetModel* columnModel = new PreviewWidgetModel(this);
    m_previewWidgetModels.append(columnModel);
}

void PreviewModel::setWidgetColumnCount(int count)
{
    if (count != 1) {
        qWarning("PreviewModel::setWidgetColumnCount != 1 not implemented");
    }
}

int PreviewModel::widgetColumnCount() const
{
    return 1;
}

bool PreviewModel::loaded() const
{
    return true;
}

bool PreviewModel::processingAction() const
{
    return false;
}

int PreviewModel::rowCount(const QModelIndex&) const
{
    return m_previewWidgetModels.size();
}

QVariant PreviewModel::data(const QModelIndex& index, int role) const
{
    switch (role) {
        case RoleColumnModel:
            return QVariant::fromValue(m_previewWidgetModels.at(index.row()));
        default:
            return QVariant();
    }
}
