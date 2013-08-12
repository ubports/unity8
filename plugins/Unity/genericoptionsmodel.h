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

#ifndef GENERICOPTIONSMODEL_H
#define GENERICOPTIONSMODEL_H

// Qt
#include <QObject>
#include <QAbstractListModel>
#include <QHash>
#include <QVector>

class AbstractFilterOption;

class Q_DECL_EXPORT GenericOptionsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

Q_SIGNALS:
    void activeChanged(AbstractFilterOption *option);

public:
    GenericOptionsModel(QObject *parent = nullptr);
    ~GenericOptionsModel();

    enum Roles {
        RoleId,
        RoleName,
        RoleIconHint,
        RoleActive
    };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    AbstractFilterOption* getRawOption(QVector<AbstractFilterOption *>::size_type idx) const;

public Q_SLOTS:
    virtual void ensureTheOnlyActive(AbstractFilterOption *activeOption);

protected Q_SLOTS:
    void onOptionChanged();
    void onActiveChanged();

protected:
    void addOption(AbstractFilterOption *option, int index);
    void removeOption(int index);
    int indexOf(const QString &option_id);

    QVector<AbstractFilterOption *> m_options;
private:
    void setupRoles();
    QHash<int, QByteArray> m_roles;
};

Q_DECLARE_METATYPE(GenericOptionsModel*)

#endif // GENERICOPTIONSMODEL_H
