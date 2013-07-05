#include "quicklistmodel.h"

QuickListModel::QuickListModel(QObject *parent) :
    QuickListModelInterface(parent)
{

}

QuickListModel::~QuickListModel()
{

}

void QuickListModel::appendAction(const QuickListEntry &entry)
{
    beginInsertRows(QModelIndex(), m_list.count() - 1, m_list.count() -1);
    m_list.append(entry);
    endInsertRows();
}

QuickListEntry QuickListModel::get(int index) const
{
    return m_list.at(index);
}

int QuickListModel::rowCount(const QModelIndex &index) const
{
    return m_list.count();
}

QVariant QuickListModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleLabel:
        return m_list.at(index.row()).text();
    case RoleIcon:
        return m_list.at(index.row()).icon();
    }
    return QVariant();
}
