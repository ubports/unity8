/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include <QSortFilterProxyModel>

#include <unity/shell/launcher/AppDrawerModelInterface.h>

using namespace unity::shell::launcher;

class AppDrawerProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(GroupBy group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QString filterLetter READ filterLetter WRITE setFilterLetter NOTIFY filterLetterChanged)
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)
    Q_PROPERTY(SortBy sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum GroupBy {
        GroupByNone,
        GroupByAll,
        GroupByAToZ
    };
    Q_ENUM(GroupBy)
    enum SortBy {
        SortByAToZ,
        SortByUsage
    };
    Q_ENUM(SortBy)

    AppDrawerProxyModel(QObject* parent = nullptr);

    QAbstractItemModel* source() const;
    void setSource(QAbstractItemModel* source);

    GroupBy group() const;
    void setGroup(GroupBy group);

    QString filterLetter() const;
    void setFilterLetter(const QString &filterLetter);

    QString filterString() const;
    void setFilterString(const QString &filterString);

    SortBy sortBy() const;
    void setSortBy(SortBy sortBy);

    int count() const;

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QString appId(int index) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

Q_SIGNALS:
    void sourceChanged();
    void groupChanged();
    void filterLetterChanged();
    void filterStringChanged();
    void sortByChanged();
    void countChanged();

private:
    QAbstractItemModel* m_source = nullptr;
    GroupBy m_group = GroupByNone;
    QString m_filterLetter;
    QString m_filterString;
    SortBy m_sortBy = SortByAToZ;
};
