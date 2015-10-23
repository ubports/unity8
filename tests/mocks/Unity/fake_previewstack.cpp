/*
 * Copyright (C) 2014 Canonical, Ltd.
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
#include "fake_previewstack.h"

// local
#include "fake_previewmodel.h"
#include "fake_scope.h"

PreviewStack::PreviewStack(Scope *scope)
 : unity::shell::scopes::PreviewStackInterface(nullptr)
{
    m_previews << new PreviewModel(this, scope);
}

PreviewStack::~PreviewStack()
{
}

void PreviewStack::setWidgetColumnCount(int columnCount)
{
    if (columnCount != 1) {
        qFatal("PreviewStack::setWidgetColumnCount != 1 not implemented");
    }
}

int PreviewStack::widgetColumnCount() const
{
    return 1;
}

int PreviewStack::rowCount(const QModelIndex&) const
{
    return m_previews.size();
}

unity::shell::scopes::PreviewModelInterface* PreviewStack::getPreviewModel(int index) const
{
    if (index >= m_previews.size()) {
        return nullptr;
    }

    return m_previews.at(index);
}

QVariant PreviewStack::data(const QModelIndex& index, int role) const
{
    switch (role) {
        case RolePreviewModel:
            return QVariant::fromValue(m_previews.at(index.row()));
        default:
            return QVariant();
    }
}
