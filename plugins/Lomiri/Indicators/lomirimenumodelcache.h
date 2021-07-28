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

#ifndef LOMIRIMENUMODELCACHE_H
#define LOMIRIMENUMODELCACHE_H

#include "lomiriindicatorsglobal.h"

#include <QObject>
#include <QHash>
#include <QPointer>
#include <QSharedPointer>

class UnityMenuModel;

class LOMIRIINDICATORS_EXPORT LomiriMenuModelCache : public QObject
{
    Q_OBJECT
public:
    LomiriMenuModelCache(QObject*parent=nullptr);

    static LomiriMenuModelCache* singleton();

    virtual QSharedPointer<UnityMenuModel> model(const QByteArray& path);

    // for tests use
    Q_INVOKABLE virtual bool contains(const QByteArray& path);

protected:
    QHash<QByteArray, QSharedPointer<UnityMenuModel>> m_registry;
    static QPointer<LomiriMenuModelCache> theCache;
};

#endif // LOMIRIMENUMODELCACHE_H
