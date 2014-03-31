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


#ifndef FAKE_PREVIEWMODEL_H
#define FAKE_PREVIEWMODEL_H

#include <QAbstractListModel>
#include <QSharedPointer>
#include <QVariantMap>

class PreviewWidgetModel;

class PreviewModel : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(int widgetColumnCount READ widgetColumnCount WRITE setWidgetColumnCount NOTIFY widgetColumnCountChanged)
    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)
    Q_PROPERTY(bool processingAction READ processingAction NOTIFY processingActionChanged)

public:
    explicit PreviewModel(QObject* parent = 0);

    enum Roles {
        RoleColumnModel
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    void setWidgetColumnCount(int count);
    int widgetColumnCount() const;
    bool loaded() const;
    bool processingAction() const;
    void setProcessingAction(bool processing);

Q_SIGNALS:
    void widgetColumnCountChanged();
    void loadedChanged();
    void processingActionChanged();
    void triggered(QString const&, QString const&, QVariantMap const&);

private:
    QHash<int, QByteArray> m_roles;
    QList<PreviewWidgetModel*> m_previewWidgetModels;
};

Q_DECLARE_METATYPE(PreviewModel*)

#endif // FAKE_PREVIEWMODEL_H
