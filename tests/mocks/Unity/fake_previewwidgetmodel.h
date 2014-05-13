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


#ifndef FAKE_PREVIEWWIDGETMODEL_H
#define FAKE_PREVIEWWIDGETMODEL_H

#include <QAbstractListModel>
#include <QSharedPointer>
#include <QVariantMap>

class PreviewData;

class PreviewWidgetModel : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

public:
    explicit PreviewWidgetModel(QObject* parent = 0);

    enum Roles {
        RoleWidgetId,
        RoleType,
        RoleProperties
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

private:
    QHash<int, QByteArray> m_roles;
    QList<QSharedPointer<PreviewData>> m_previewWidgets;

    void populateWidgets();

};

Q_DECLARE_METATYPE(PreviewWidgetModel*)

#endif // FAKE_PREVIEWWIDGETMODEL_H
