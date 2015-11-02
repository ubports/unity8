/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef APPLICATIONSFILTERMODEL_H
#define APPLICATIONSFILTERMODEL_H

#include <QSortFilterProxyModel>

namespace unity {
namespace shell {
namespace application {
class ApplicationManagerInterface;
class ApplicationInfoInterface;
}
}
}
using namespace unity::shell::application;

class ApplicationsFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(unity::shell::application::ApplicationManagerInterface* applicationsModel READ applicationsModel WRITE setApplicationsModel NOTIFY applicationsModelChanged)
    Q_PROPERTY(bool filterTouchApps READ filterTouchApps WRITE setFilterTouchApps NOTIFY filterTouchAppsChanged)
    Q_PROPERTY(bool filterLegacyApps READ filterLegacyApps WRITE setFilterLegacyApps NOTIFY filterLegacyAppsChanged)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    ApplicationsFilterModel(QObject *parent = 0);

    ApplicationManagerInterface* applicationsModel() const;
    void setApplicationsModel(ApplicationManagerInterface* applicationsModel);

    bool filterTouchApps() const;
    void setFilterTouchApps(bool filterTouchApps);

    bool filterLegacyApps() const;
    void setFilterLegacyApps(bool filterLegacyApps);

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE unity::shell::application::ApplicationInfoInterface* get(int index) const;

Q_SIGNALS:
    void applicationsModelChanged();
    void filterTouchAppsChanged();
    void filterLegacyAppsChanged();
    void countChanged();

private:
    ApplicationManagerInterface* m_appModel;
    bool m_filterTouchApps;
    bool m_filterLegacyApps;
};

#endif
