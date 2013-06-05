/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef APPLICATION_LIST_MODEL_H
#define APPLICATION_LIST_MODEL_H

#include <QAbstractListModel>
#include <QQmlListProperty>
#include "ApplicationInfo.h"

class ApplicationManager;

class ApplicationListModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QQmlListProperty<ApplicationInfo> applications READ applications)
    Q_CLASSINFO("DefaultProperty", "applications")

 public:
    explicit ApplicationListModel(QObject* parent = 0);
    virtual ~ApplicationListModel();

    // QAbstractItemModel methods.
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role) const;
    QHash<int,QByteArray> roleNames() const { return m_roleNames; }
    Q_INVOKABLE QVariant get(int index) const;
    Q_INVOKABLE void move(int from, int to);

    QQmlListProperty<ApplicationInfo> applications();

    Q_INVOKABLE void add(ApplicationInfo* application);
    Q_INVOKABLE void remove(ApplicationInfo* application);
    Q_INVOKABLE bool contains(ApplicationInfo* application) const;
    Q_INVOKABLE void clear();

 Q_SIGNALS:
    void countChanged();

 private:
    Q_DISABLE_COPY(ApplicationListModel)

    static void appendApplication(QQmlListProperty<ApplicationInfo> *list,
                                  ApplicationInfo *application);
    static int countApplications(QQmlListProperty<ApplicationInfo> *list);
    static ApplicationInfo* atApplication(QQmlListProperty<ApplicationInfo> *list, int index);
    static void clearApplications(QQmlListProperty<ApplicationInfo> *list);

    QHash<int,QByteArray> m_roleNames;
    QList<ApplicationInfo*> m_applications;

    friend class ApplicationManager;
};

Q_DECLARE_METATYPE(ApplicationListModel*)

#endif  // APPLICATION_LIST_MODEL_H
