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


#ifndef FAKE_PREVIEWSTACK_H
#define FAKE_PREVIEWSTACK_H

#include <QAbstractListModel>
#include <QSharedPointer>
#include <QVariantMap>

class PreviewModel;

class PreviewStack : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(int widgetColumnCount READ widgetColumnCount WRITE setWidgetColumnCount NOTIFY widgetColumnCountChanged)

public:
    explicit PreviewStack(QObject* parent = 0);
    virtual ~PreviewStack();

    enum Roles {
        RolePreviewModel
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    Q_INVOKABLE PreviewModel* get(int index) const;

    void setWidgetColumnCount(int columnCount);
    int widgetColumnCount() const;

Q_SIGNALS:
    void widgetColumnCountChanged();

private:
    QList<PreviewModel*> m_previews;
};

Q_DECLARE_METATYPE(PreviewStack*)

#endif // FAKE_PREVIEWSTACK_H
