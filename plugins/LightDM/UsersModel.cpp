/*
 * Copyright (C) 2013,2015-2016 Canonical, Ltd.
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

#include "Greeter.h"
#include "UsersModel.h"
#include <QIdentityProxyModel>
#include <QLightDM/UsersModel>

#include <libintl.h>

// First, we define an internal class that wraps LightDM's UsersModel.  This
// class will modify some of the data coming from LightDM.  For example, we
// modify any empty Real Names into just normal Names.  We also add optional
// rows, depending on configuration.
// (We can't modify the data directly in UsersModel below because it won't sort
// using the modified data.)
class MangleModel : public QIdentityProxyModel
{
    Q_OBJECT

public:
    explicit MangleModel(QObject* parent=0);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;

private:
    struct CustomRow {
        QString name;
        QString realName;
    };

    void addCustomRow(const CustomRow &newRow);
    void removeCustomRow(const QString &rowName);
    void updateGuestRow();
    void updateManualRow();

    QList<CustomRow> m_customRows;
};

MangleModel::MangleModel(QObject* parent)
  : QIdentityProxyModel(parent)
{
    if (!Greeter::instance()->hideUsersHint()) {
        setSourceModel(new QLightDM::UsersModel(this));
    }

    updateGuestRow();
    updateManualRow();

    // Would be nice if there were a rowCountChanged signal in the base class
    connect(this, &QIdentityProxyModel::modelReset,
            this, &MangleModel::updateManualRow);
    connect(this, &QIdentityProxyModel::rowsInserted,
            this, &MangleModel::updateManualRow);
    connect(this, &QIdentityProxyModel::rowsRemoved,
            this, &MangleModel::updateManualRow);
}

QVariant MangleModel::data(const QModelIndex &index, int role) const
{
    QVariant variantData;

    bool isCustomRow = index.row() >= sourceModel()->rowCount() &&
                       index.row() < rowCount();
    if (isCustomRow && index.column() == 0) {
        int customIndex = index.row() - sourceModel()->rowCount();
        if (role == QLightDM::UsersModel::NameRole) {
            variantData = m_customRows[customIndex].name;
        } else if (role == QLightDM::UsersModel::RealNameRole) {
            variantData = m_customRows[customIndex].realName;
        } else if (role == QLightDM::UsersModel::LoggedInRole) {
            variantData = false;
        } else if (role == QLightDM::UsersModel::SessionRole) {
            variantData = Greeter::instance()->defaultSessionHint();
        }
    } else {
        variantData = QIdentityProxyModel::data(index, role);
    }

    // If user's real name is empty, switch to unix name
    if (role == QLightDM::UsersModel::RealNameRole && variantData.toString().isEmpty()) {
        variantData = data(index, QLightDM::UsersModel::NameRole);
    } else if (role == QLightDM::UsersModel::BackgroundPathRole && variantData.toString().startsWith('#')) {
        const QString stringData = "data:image/svg+xml,<svg><rect width='100%' height='100%' fill='" + variantData.toString() + "'/></svg>";
        variantData = stringData;
    }

    return variantData;
}

void MangleModel::addCustomRow(const CustomRow &newRow)
{
    for (int i = 0; i < m_customRows.size(); i++) {
        if (m_customRows[i].name == newRow.name) {
            return; // we don't have custom rows that change content yet
        }
    }

    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_customRows << newRow;
    endInsertRows();
}

void MangleModel::removeCustomRow(const QString &rowName)
{
    for (int i = 0; i < m_customRows.size(); i++) {
        if (m_customRows[i].name == rowName) {
            int rowNum = sourceModel()->rowCount() + i;
            beginRemoveRows(QModelIndex(), rowNum, rowNum);
            m_customRows.removeAt(i);
            endRemoveRows();
            break;
        }
    }
}

void MangleModel::updateManualRow()
{
    bool hasAnotherEntry = sourceModel()->rowCount() > 0;
    for (int i = 0; !hasAnotherEntry && i < m_customRows.size(); i++) {
        if (m_customRows[i].name != QStringLiteral("*other")) {
            hasAnotherEntry = true;
        }
    }

    // Show manual login if we are asked to OR if no other entry exists
    if (Greeter::instance()->showManualLoginHint() || !hasAnotherEntry)
        addCustomRow({QStringLiteral("*other"), gettext("Login")});
    else
        removeCustomRow(QStringLiteral("*other"));
}

void MangleModel::updateGuestRow()
{
    if (Greeter::instance()->hasGuestAccount())
        addCustomRow({QStringLiteral("*guest"), gettext("Guest Session")});
    else
        removeCustomRow(QStringLiteral("*guest"));
}

int MangleModel::rowCount(const QModelIndex &parent) const
{
    return QIdentityProxyModel::rowCount(parent) +
           (parent.isValid() ? 0 : m_customRows.size());
}

QModelIndex MangleModel::index(int row, int column, const QModelIndex &parent) const
{
    bool isCustomRow = row >= sourceModel()->rowCount() &&
                       row < rowCount();
    if (isCustomRow && !parent.isValid()) {
        return createIndex(row, column);
    } else {
        return QIdentityProxyModel::index(row, column, parent);
    }
}

// **** Now we continue with actual UsersModel class ****

UsersModel::UsersModel(QObject* parent)
  : UnitySortFilterProxyModelQML(parent)
{
    setModel(new MangleModel(this));
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    setSortRole(QLightDM::UsersModel::RealNameRole);
    sort(0);
}

bool UsersModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    auto leftName = source_left.data(QLightDM::UsersModel::NameRole);
    auto rightName = source_right.data(QLightDM::UsersModel::NameRole);

    if (leftName == QStringLiteral("*guest"))
        return false;
    if (rightName == QStringLiteral("*guest"))
        return true;
    if (leftName == QStringLiteral("*other"))
        return false;
    if (rightName == QStringLiteral("*other"))
        return true;

    return UnitySortFilterProxyModelQML::lessThan(source_left, source_right);
}

#include "UsersModel.moc"
