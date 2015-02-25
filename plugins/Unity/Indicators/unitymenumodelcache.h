/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef UNITYMENUMODELCACHE_H
#define UNITYMENUMODELCACHE_H

#include "unityindicatorsglobal.h"

#include <QObject>
#include <QHash>
#include <QPointer>
#include <QSharedPointer>

class UnityMenuModel;

class UNITYINDICATORS_EXPORT UnityMenuModelCache : public QObject
{
    Q_OBJECT
public:
    UnityMenuModelCache(QObject*parent=nullptr);

    static UnityMenuModelCache* singleton();

    virtual QSharedPointer<UnityMenuModel> model(const QByteArray& path);

    // for tests use
    Q_INVOKABLE virtual bool contains(const QByteArray& path);

protected:
    QHash<QByteArray, QSharedPointer<UnityMenuModel>> m_registry;
    static QPointer<UnityMenuModelCache> theCache;
};

#endif // UNITYMENUMODELCACHE_H
