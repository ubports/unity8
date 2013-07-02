#include "applicationlistmodel.h"

#include <QDebug>

ApplicationListModel::ApplicationListModel(QObject *parent):
    QAbstractListModel(parent)
{

}

void ApplicationListModel::addApplication(const QString &appId, int index)
{
    beginInsertRows(QModelIndex(), index, index);
    qDebug() << "inserting" << appId << "at" << index;
    m_list.insert(index, appId);
    endInsertRows();
}

void ApplicationListModel::removeApplication(const QString &appId)
{

}

void ApplicationListModel::moveApplication(const QString &appId, int newIndex)
{

}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    return m_list.count();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (role == RoleAppId) {
        return m_list.at(index.row());
    }
    return QVariant();
}
