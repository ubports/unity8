/*
 * Copyright 2015 Canonical Ltd.
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
 *      Mirco Mueller <mirco.mueller@canonical.com>
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

    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void append(MockNotification* n);
    MockNotification* getNotification(unsigned int id) const;
    MockNotification* getNotification(const QString &summary) const;
    bool hasNotification(unsigned int id) const;

    // getRaw() is only meant to be used from QML, since QML cannot handle
    // QSharedPointers... on C++-side only use getNotification()
    Q_INVOKABLE MockNotification* getRaw(const unsigned int notificationId) const;

    Q_INVOKABLE int queued() const;
    Q_INVOKABLE void remove(const unsigned int id);

    int getCount() const;

private Q_SLOTS:
    void onDataChanged(unsigned int id);

Q_SIGNALS:
    void queueSizeChanged(int newSize);

private:
    QList<MockNotification*> m_queue;
    void deleteFromVisible(int loc);
    void deleteFirst();
};

#endif
