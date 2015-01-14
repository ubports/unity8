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

#include "MockNotificationModel.h"
#include "MockNotification.h"

#include <unity/shell/notifications/ModelInterface.h>

#include <QTimer>
#include <QList>
#include <QVector>
#include <QMap>
#include <QStringListModel>
#include <QQmlEngine>
#include <QDebug>

using namespace unity::shell::notifications;

struct MockNotificationModelPrivate {
    QList<QSharedPointer<MockNotification> > queue;
};

MockNotificationModel::MockNotificationModel(QObject *parent) : QAbstractListModel(parent), p(new MockNotificationModelPrivate) {
}

MockNotificationModel::~MockNotificationModel() {
}

int MockNotificationModel::rowCount(const QModelIndex &parent) const {
    return p->queue.size();
}

QVariant MockNotificationModel::data(const QModelIndex &index, int role) const {
    //printf("Data %d.\n", index.row());
    if (!index.isValid())
            return QVariant();

    switch(role) {
        case ModelInterface::RoleType:
            return QVariant(p->queue[index.row()]->getType());

        case ModelInterface::RoleId:
            return QVariant(p->queue[index.row()]->getID());

        case ModelInterface::RoleSummary:
            return QVariant(p->queue[index.row()]->getSummary());

        case ModelInterface::RoleBody:
            return QVariant(p->queue[index.row()]->getBody());

        case ModelInterface::RoleValue:
            return QVariant(p->queue[index.row()]->getValue());

        case ModelInterface::RoleIcon:
            return QVariant(p->queue[index.row()]->getIcon());

        case ModelInterface::RoleSecondaryIcon:
            return QVariant(p->queue[index.row()]->getSecondaryIcon());

        case ModelInterface::RoleActions:
            return QVariant::fromValue(p->queue[index.row()]->getActions());

        case ModelInterface::RoleHints:
            return QVariant(p->queue[index.row()]->getHints());

        case ModelInterface::RoleNotification:
            return QVariant(p->queue[index.row()]);

        default:
            return QVariant();
    }
}

void MockNotificationModel::append(const QSharedPointer<MockNotification> &n) {
    p->queue.append(n);
    //qDebug() << "append() called, count:" << p->queue.size() << ", summary: " << QString(p->queue[0]->getSummary());
}

QSharedPointer<MockNotification> MockNotificationModel::getNotification(unsigned int id) const {
    for(int i=0; i<p->queue.size(); i++) {
        if(p->queue[i]->getID() == id) {
            return p->queue[i];
        }
    }

    QSharedPointer<MockNotification> empty;
    return empty;
}

QSharedPointer<MockNotification> MockNotificationModel::getNotification(const QString &summary) const {
    for(int i=0; i<p->queue.size(); i++) {
        if(p->queue[i]->getSummary() == summary) {
            return p->queue[i];
        }
    }

    QSharedPointer<MockNotification> empty;
    return empty;
}

bool MockNotificationModel::hasNotification(unsigned int id) const {
    return !(getNotification(id) != nullptr);
}

void MockNotificationModel::removeNotification(const unsigned int id) {
    for(int i=0; i<p->queue.size(); i++) {
        if(p->queue[i]->getID() == id) {
            deleteFromVisible(i);
            return;
        }
    }
    // The ID was not found in any queue. Should it be an error case or not?
}

void MockNotificationModel::deleteFirst() {
    if(p->queue.empty())
        return;
    deleteFromVisible(0);
}

void MockNotificationModel::deleteFromVisible(int loc) {
    QModelIndex deletePoint = QModelIndex();
    beginRemoveRows(deletePoint, loc, loc);
    p->queue.erase(p->queue.begin() + loc);
    endRemoveRows();
}

MockNotification* MockNotificationModel::getRaw(const unsigned int notificationId) const {
    for(int i=0; i<p->queue.size(); i++) {
        if(p->queue[i]->getID() == notificationId) {
            MockNotification* n = p->queue[i].data();
            QQmlEngine::setObjectOwnership(n, QQmlEngine::CppOwnership);
            return n;
        }
    }

    return nullptr;
}

int MockNotificationModel::queued() const {
    return p->queue.size();
}

QHash<int, QByteArray> MockNotificationModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles.insert(ModelInterface::RoleType, "type");
    roles.insert(ModelInterface::RoleUrgency, "urgency");
    roles.insert(ModelInterface::RoleId, "nid");
    roles.insert(ModelInterface::RoleSummary, "summary");
    roles.insert(ModelInterface::RoleBody, "body");
    roles.insert(ModelInterface::RoleValue, "value");
    roles.insert(ModelInterface::RoleIcon, "icon");
    roles.insert(ModelInterface::RoleSecondaryIcon, "secondaryIcon");
    roles.insert(ModelInterface::RoleActions, "actions");
    roles.insert(ModelInterface::RoleHints, "hints");
    roles.insert(ModelInterface::RoleNotification, "notification");

    return roles;
}

void MockNotificationModel::onDataChanged(unsigned int id) {
    for(int i=0; i<p->queue.size(); i++) {
        if(p->queue[i]->getID() == id) {
            Q_EMIT dataChanged(index(i, 0), index(i, 0));
            break;
        }
    }
}
