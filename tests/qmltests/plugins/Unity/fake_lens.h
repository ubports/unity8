/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef FAKE_LENS_H
#define FAKE_LENS_H

// Qt
#include <QObject>
#include "categories.h"

class Lens : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(Categories* categories READ categories NOTIFY categoriesChanged)

public:
    Lens(QObject* parent = 0);
    Lens(QString const& id, QString const& name, bool visible, QObject* parent = 0);

    QString id() const;
    QString name() const;
    QString searchQuery() const;
    bool visible() const;

    void setName(const QString &str);
    void setSearchQuery(const QString &str);

    Categories* categories() const;

Q_SIGNALS:
    void idChanged(QString);
    void nameChanged(QString);
    void searchQueryChanged(QString);
    void visibleChanged(bool);
    void categoriesChanged();

private:
    QString m_id;
    QString m_name;
    QString m_searchQuery;
    bool m_visible;
    Categories* m_categories;
    DeeListModel* m_results;
};

#endif // FAKE_LENS_H
