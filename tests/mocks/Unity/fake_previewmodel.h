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

#include <unity/shell/scopes/PreviewModelInterface.h>

#include <QSharedPointer>
#include <QVariantMap>

class PreviewWidgetModel;

class Scope;

class PreviewModel : public unity::shell::scopes::PreviewModelInterface
{
    Q_OBJECT

public:
    explicit PreviewModel(QObject* parent = 0, Scope* scope = 0);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    void setWidgetColumnCount(int count) override;
    int widgetColumnCount() const override;
    bool loaded() const override;
    bool processingAction() const override;

    Q_INVOKABLE void setLoaded(bool); // Only available for testing

private Q_SLOTS:
    void triggeredSlot(QString const&, QString const&, QVariantMap const&);

private:
    QList<PreviewWidgetModel*> m_previewWidgetModels;
    bool m_loaded;
    Scope* m_scope;
};

Q_DECLARE_METATYPE(PreviewModel*)

#endif // FAKE_PREVIEWMODEL_H
