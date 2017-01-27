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

#pragma once

#include <QAbstractListModel>

class PromptsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum PromptsModelRoles {
        TypeRole = Qt::UserRole,
        TextRole,
    };
    Q_ENUM(PromptsModelRoles)

    enum PromptType {
        Message,
        Error,
        Secret,
        Question,
        Button,
    };
    Q_ENUM(PromptType)

    explicit PromptsModel(QObject* parent=0);

    PromptsModel& operator=(const PromptsModel &other);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void prepend(const QString &text, PromptType type);
    Q_INVOKABLE void append(const QString &text, PromptType type);

    void clear();

    bool hasPrompt() const;

Q_SIGNALS:
    void countChanged();

private:
    struct PromptInfo {
        QString prompt;
        PromptType type;
    };

    QList<PromptInfo> m_prompts;
    QHash<int, QByteArray> m_roleNames;
};
