/*
 * Copyright 2014 Canonical Ltd.
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
 */

#ifndef FAKEUNITYMENUMODELCACHE_H
#define FAKEUNITYMENUMODELCACHE_H

#include "unitymenumodelcache.h"

#include <QVariantMap>

class FakeUnityMenuModelCache : public UnityMenuModelCache
{
    Q_OBJECT
public:
    FakeUnityMenuModelCache(QObject* parent = nullptr);

    static FakeUnityMenuModelCache* singleton();

    QSharedPointer<UnityMenuModel> model(const QByteArray& path) override;
    bool contains(const QByteArray& path) override;

    Q_INVOKABLE void setCachedModelData(const QByteArray& path,
                                        const QVariant& data = QVariant());

    Q_INVOKABLE QVariant getCachedModelData(const QByteArray& path);

private:
    static QPointer<FakeUnityMenuModelCache> theFakeCache;
    QHash<QByteArray, QSharedPointer<UnityMenuModel>> m_models;
};

#endif // FAKEUNITYMENUMODELCACHE_H
