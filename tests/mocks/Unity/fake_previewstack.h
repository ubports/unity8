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

#include <unity/shell/scopes/PreviewStackInterface.h>

#include <QSharedPointer>
#include <QVariantMap>

class PreviewModel;

class Scope;

class PreviewStack : public unity::shell::scopes::PreviewStackInterface
{
    Q_OBJECT

public:
    explicit PreviewStack(Scope* scope = 0);
    virtual ~PreviewStack();

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    Q_INVOKABLE unity::shell::scopes::PreviewModelInterface* getPreviewModel(int index) const override;

    void setWidgetColumnCount(int columnCount) override;
    int widgetColumnCount() const override;

private:
    QList<PreviewModel*> m_previews;
};

Q_DECLARE_METATYPE(PreviewStack*)

#endif // FAKE_PREVIEWSTACK_H
