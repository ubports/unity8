/*
 * Copyright 2015-2016 Canonical Ltd.
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
 */

#ifndef MOCK_NOTIFICATION_MODEL_H
#define MOCK_NOTIFICATION_MODEL_H

#include <QAbstractListModel>
#include <QSharedPointer>
#include <QScopedPointer>
#include "MockNotification.h"

class MockNotification;

class MockNotificationModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ getCount)

public:
    MockNotificationModel(QObject *parent=nullptr);
    virtual ~MockNotificationModel();

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void append(MockNotification* n);
    MockNotification* getNotification(int id) const;

    // getRaw() is only meant to be used from QML, since QML cannot handle
    // QSharedPointers... on C++-side only use getNotification()
    Q_INVOKABLE MockNotification* getRaw(const int notificationId) const;

    Q_INVOKABLE int queued() const;
    Q_INVOKABLE void remove(const int id);
    Q_INVOKABLE void removeFirst();

    int getCount() const;

Q_SIGNALS:
    void actionInvoked(const QString &action);

public Q_SLOTS:
    void onCompleted(int id);

private Q_SLOTS:
    void onDataChanged(int id);

Q_SIGNALS:
    void queueSizeChanged(int newSize);

private:
    QList<MockNotification*> m_queue;
    void removeInternal(int loc);
};

#endif
