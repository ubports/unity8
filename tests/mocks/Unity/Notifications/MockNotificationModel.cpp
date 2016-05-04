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

using namespace unity::shell::notifications;

MockNotificationModel::MockNotificationModel(QObject *parent) : QAbstractListModel(parent) {
}

MockNotificationModel::~MockNotificationModel() {
    Q_FOREACH(MockNotification *n, m_queue) {
        n->deleteLater();
    }
    m_queue.clear();
}

int MockNotificationModel::rowCount(const QModelIndex &) const {
    return m_queue.size();
}

int MockNotificationModel::getCount() const {
    return m_queue.size();
}

QVariant MockNotificationModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    switch(role) {
        case ModelInterface::RoleType:
            return QVariant(m_queue[index.row()]->getType());

        case ModelInterface::RoleId:
            return QVariant(m_queue[index.row()]->getID());

        case ModelInterface::RoleSummary:
            return QVariant(m_queue[index.row()]->getSummary());

        case ModelInterface::RoleBody:
            return QVariant(m_queue[index.row()]->getBody());

        case ModelInterface::RoleValue:
            return QVariant(m_queue[index.row()]->getValue());

        case ModelInterface::RoleIcon:
            return QVariant(m_queue[index.row()]->getIcon());

        case ModelInterface::RoleSecondaryIcon:
            return QVariant(m_queue[index.row()]->getSecondaryIcon());

        case ModelInterface::RoleActions:
            return QVariant::fromValue(m_queue[index.row()]->getActions());

        case ModelInterface::RoleHints:
            return QVariant(m_queue[index.row()]->getHints());

        case ModelInterface::RoleNotification:
            return QVariant::fromValue(m_queue[index.row()]);

        default:
            return QVariant();
    }
}

void MockNotificationModel::append(MockNotification* n) {
    int location = m_queue.size();
    QModelIndex insertionPoint = QModelIndex();
    beginInsertRows(insertionPoint, location, location);
    m_queue.insert(location, n);
    endInsertRows();
}

MockNotification* MockNotificationModel::getNotification(int id) const {
    for(int i=0; i < m_queue.size(); i++) {
        if(m_queue[i]->getID() == id) {
            return m_queue[i];
        }
    }

    return nullptr;
}

void MockNotificationModel::remove(const int id) {
    for(int i = 0; i < m_queue.size(); i++) {
        if(m_queue[i]->getID() == id) {
            removeInternal(i);
            return;
        }
    }
}

void MockNotificationModel::removeSecond() {
    if(m_queue.size() < 2)
        return;
    removeInternal(1);
}

void MockNotificationModel::removeInternal(int loc) {
    QModelIndex deletePoint = QModelIndex();
    beginRemoveRows(deletePoint, loc, loc);
    m_queue.erase(m_queue.begin() + loc);
    endRemoveRows();
}

MockNotification* MockNotificationModel::getRaw(const int notificationId) const {
    for(int i = 0; i < m_queue.size(); i++) {
        if(m_queue[i]->getID() == notificationId) {
            MockNotification* n = m_queue[i];
            return n;
        }
    }

    return nullptr;
}

int MockNotificationModel::queued() const {
    return m_queue.size();
}

QHash<int, QByteArray> MockNotificationModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles.insert(ModelInterface::RoleType, "type");
    roles.insert(ModelInterface::RoleUrgency, "urgency");
    roles.insert(ModelInterface::RoleId, "id");
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

void MockNotificationModel::onCompleted(int id) {
    remove(id);
}

void MockNotificationModel::onDataChanged(int id) {
    for(int i = 0; i < m_queue.size(); i++) {
        if(m_queue[i]->getID() == id) {
            Q_EMIT dataChanged(index(i, 0), index(i, 0));
            break;
        }
    }
}
