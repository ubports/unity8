/*
 * Copyright (C) 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef KEYBOARDLAYOUTSMODEL_H
#define KEYBOARDLAYOUTSMODEL_H

#include <QAbstractListModel>

struct KeyboardLayoutInfo {
    QString id;
    QString displayName;
    QString language;
};

class KeyboardLayoutsModel: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    explicit KeyboardLayoutsModel(QObject * parent = nullptr);
    ~KeyboardLayoutsModel() = default;

    enum Roles {
        LayoutIdRole = Qt::UserRole + 1,
        DisplayNameRole,
        LanguageRole
    };

    QString language() const;
    void setLanguage(const QString &language);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void languageChanged(const QString &language);

private Q_SLOTS:
    void updateModel();

private:
    void buildModel();

    QString m_language;
    QHash<int, QByteArray> m_roleNames;
    QVector<KeyboardLayoutInfo> m_layouts;
    QVector<KeyboardLayoutInfo> m_db;
};

#endif
