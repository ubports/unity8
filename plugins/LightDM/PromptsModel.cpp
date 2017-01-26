/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "PromptsModel.h"

PromptsModel::PromptsModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_roleNames[TypeRole] = "type";
    m_roleNames[TextRole] = "text";
}

PromptsModel& PromptsModel::operator=(const PromptsModel &other)
{
    beginResetModel();
    m_prompts = other.m_prompts;
    endResetModel();
    Q_EMIT countChanged();
    return *this;
}

int PromptsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_prompts.size();
}

QVariant PromptsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 || index.row() >= m_prompts.size())
        return QVariant();

    switch (role) {
    case Qt::DisplayRole: // fallthrough
    case TextRole:        return m_prompts[index.row()].prompt;
    case TypeRole:        return m_prompts[index.row()].type;
    default:              return QVariant();
    }
}

QHash<int, QByteArray> PromptsModel::roleNames() const
{
    return m_roleNames;
}

void PromptsModel::prepend(const QString &text, PromptType type)
{
    beginInsertRows(QModelIndex(), 0, 0);
    m_prompts.prepend(PromptInfo{text, type});
    endInsertRows();

    Q_EMIT countChanged();
}

void PromptsModel::append(const QString &text, PromptType type)
{
    beginInsertRows(QModelIndex(), m_prompts.size(), m_prompts.size());
    m_prompts.append(PromptInfo{text, type});
    endInsertRows();

    Q_EMIT countChanged();
}

void PromptsModel::clear()
{
    beginResetModel();
    m_prompts.clear();
    endResetModel();

    Q_EMIT countChanged();
}

bool PromptsModel::hasPrompt() const
{
    Q_FOREACH(const PromptInfo &info, m_prompts) {
        if (info.type == PromptType::Secret || info.type == PromptType::Question) {
            return true;
        }
    }
    return false;
}
