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

#include "ApplicationListModel.h"
#include "ApplicationInfo.h"

ApplicationListModel::ApplicationListModel(QObject* parent)
    : QAbstractListModel(parent), m_applications()
{
    m_roleNames.insert(0, "application");
}

ApplicationListModel::~ApplicationListModel()
{
    const int kSize = m_applications.size();
    for (int i = 0; i < kSize; i++)
        delete m_applications.at(i);
    m_applications.clear();
}

int ApplicationListModel::rowCount(const QModelIndex& parent) const
{
    return !parent.isValid() ? m_applications.size() : 0;
}

QVariant ApplicationListModel::data(const QModelIndex& index, int role) const
{
    if (index.row() >= 0 && index.row() < m_applications.size() && role == 0)
        return QVariant::fromValue(m_applications.at(index.row()));
    else
        return QVariant();
}

QVariant ApplicationListModel::get(int row) const
{
    return data(index(row), 0);
}

void ApplicationListModel::move(int from, int to)
{
    if (from >= 0 && from < m_applications.size() && to >= 0 && to < m_applications.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */
        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_applications.move(from, to);
        endMoveRows();
    }
}

void ApplicationListModel::add(ApplicationInfo* application)
{
    beginInsertRows(QModelIndex(), m_applications.size(), m_applications.size());
    m_applications.append(application);
    endInsertRows();
    Q_EMIT countChanged();
}

void ApplicationListModel::remove(ApplicationInfo* application)
{
    int i = m_applications.indexOf(application);
    if (i != -1) {
        beginRemoveRows(QModelIndex(), i, i);
        m_applications.removeAt(i);
        endRemoveRows();
        Q_EMIT countChanged();
    }
}

bool ApplicationListModel::contains(ApplicationInfo* application) const {
    return m_applications.contains(application);
}

void ApplicationListModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_applications.size()-1);
    m_applications.clear();
    endRemoveRows();
    Q_EMIT countChanged();
}

QQmlListProperty<ApplicationInfo> ApplicationListModel::applications()
{
    return QQmlListProperty<ApplicationInfo>(this, 0,
        &ApplicationListModel::appendApplication,
        &ApplicationListModel::countApplications,
        &ApplicationListModel::atApplication,
        &ApplicationListModel::clearApplications);
}

void ApplicationListModel::appendApplication(QQmlListProperty<ApplicationInfo> *list,
                                             ApplicationInfo *application)
{
    ApplicationListModel *self = qobject_cast<ApplicationListModel *>(list->object);
    if (self) {
        application->setParent(self);
        self->add(application);
    }
}

int ApplicationListModel::countApplications(QQmlListProperty<ApplicationInfo> *list)
{
    ApplicationListModel *self = qobject_cast<ApplicationListModel *>(list->object);
    if (self) {
        return self->m_applications.size();
    } else {
        return 0;
    }
}

ApplicationInfo* ApplicationListModel::atApplication(QQmlListProperty<ApplicationInfo> *list,
                                                 int index)
{
    ApplicationListModel *self = qobject_cast<ApplicationListModel *>(list->object);
    if (!self) { return 0; }

    if (index >= 0 && index < self->m_applications.size()) {
        return self->m_applications.at(index);
    } else {
        return 0;
    }
}

void ApplicationListModel::clearApplications(QQmlListProperty<ApplicationInfo> *list)
{
    ApplicationListModel *self = qobject_cast<ApplicationListModel *>(list->object);
    if (self) {
        self->clear();
    }
}
