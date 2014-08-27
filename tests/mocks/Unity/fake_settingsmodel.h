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

#ifndef FAKE_SETTINGSMODEL_H
#define FAKE_SETTINGSMODEL_H

#include <unity/shell/scopes/SettingsModelInterface.h>

#include <QList>
#include <QSharedPointer>

class SettingsModel: public unity::shell::scopes::SettingsModelInterface {
Q_OBJECT

    struct Data {
        QString id;
        QString displayName;
        QString type;
        QVariant properties;
        QVariant value;

        Data(QString const& id_, QString const& displayName_,
             QString const& type_, QVariant const& properties_,
             QVariant const& value_) :
             id(id_), displayName(displayName_), type(type_),
             properties(properties_), value(value_) {}
    };

public:
    explicit SettingsModel(QObject* parent = 0);
    ~SettingsModel() = default;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex&index, const QVariant& value, int role = Qt::EditRole) override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int count() const override;

protected:
    QList<QSharedPointer<Data>> m_data;
};

#endif // FAKE_SETTINGSMODEL_H
