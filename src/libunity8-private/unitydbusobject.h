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

#ifndef UNITYDBUSOBJECT_H
#define UNITYDBUSOBJECT_H

#include <QDBusConnection>
#include <QObject>

class Q_DECL_EXPORT UnityDBusObject : public QObject
{
    Q_OBJECT

public:
    explicit UnityDBusObject(const QString &path, const QString &service = QString(), bool async = true, QObject *parent = 0);
    ~UnityDBusObject();

    QDBusConnection connection() const;
    QString path() const;

protected:
    void notifyPropertyChanged(const QString& propertyName, const QVariant &value);

private Q_SLOTS:
    void registerObject();

private:
    QDBusConnection m_connection;
    QString m_path;
    QString m_service;
};

#endif // UNITYDBUSOBJECT_H
