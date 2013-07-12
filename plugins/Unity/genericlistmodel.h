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

#ifndef GENERICLISTMODEL_H
#define GENERICLISTMODEL_H

// Qt
#include <QObject>
#include <QAbstractListModel>

/*
 *  TODO: see if it'd be better to use QVariantListModel.
 */
class Q_DECL_EXPORT GenericListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    GenericListModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    void addObject(QObject* option);

    QList<QObject *>::Iterator optionsBegin();
    QList<QObject *>::Iterator optionsEnd();

protected:
    QList<QObject *> m_list;
};

Q_DECLARE_METATYPE(GenericListModel*)

#endif
