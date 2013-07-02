/* Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

#include <QAbstractListModel>

class ApplicationListModel: public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        RoleAppId = Qt::UserRole +1
    };

    explicit ApplicationListModel(QObject *parent = 0);

    /**
      * @brief Add an application to the list of applications.
      * @param appId The ID of the application to be added.
      */
    void addApplication(const QString &appId, int index);

    /**
      * @brief Remove an application from the list of applications.
      * @param appId The ID of the application to be removed.
      */
    void removeApplication(const QString &appId);

    /**
      * @brief Move an application within the list
      * @param appId The ID of the application to be moved.
      * @param newIndex The new position for the entry.
      */
    void moveApplication(const QString &appId, int newIndex);


    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;

private:
    QList<QString> m_list;
};

#endif // APPLICATIONLISTMODEL_H

