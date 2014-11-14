/*
 * Copyright (C) 2014 Canonical Ltd.
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

#ifndef WIZARD_PAGELIST_H
#define WIZARD_PAGELIST_H

#include <QMap>
#include <QObject>
#include <QString>

class PageList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int index READ index NOTIFY indexChanged)
    Q_PROPERTY(int numPages READ numPages NOTIFY numPagesChanged)

public:
    explicit PageList(QObject *parent = 0);

    QStringList entries() const;
    QStringList paths() const;
    int index() const;
    int numPages() const;

public Q_SLOTS:
    QString prev();
    QString next();

Q_SIGNALS:
    void indexChanged();
    void numPagesChanged(); // never emitted, just here to quiet Qml warnings

private:
    int setIndex(int index);

    int m_index;
    QMap<QString, QString> m_pages;
};

#endif // WIZARD_PAGELIST_H
