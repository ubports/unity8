/*
 * Copyright (C) 2020 UBports Foundation
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

#ifndef LOMIRI_HANDLEMEDIAKEYS_H
#define LOMIRI_HANDLEMEDIAKEYS_H

#include <QObject>
#include <QString>

class QDBusInterface;

class HandleMediaKeys: public QObject
{
    Q_OBJECT

public:
    explicit HandleMediaKeys(QObject *parent = 0);

    Q_INVOKABLE void notifyMediaKey(int key);

Q_SIGNALS:
    void mediaKey(int key);

private Q_SLOTS:
    void onMediaKey(int key);

private:
    QDBusInterface *m_broadcaster;
};

#endif
