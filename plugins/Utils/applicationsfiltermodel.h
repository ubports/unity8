#ifndef APPLICATIONSFILTERMODEL_H
#define APPLICATIONSFILTERMODEL_H

#include <QSortFilterProxyModel>

namespace unity {
namespace shell {
namespace application {
class ApplicationManagerInterface;
}
}
}
using namespace unity::shell::application;

class ApplicationsFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(ApplicationManagerInterface* applicationsModel READ applicationsModel WRITE setApplicationsModel NOTIFY applicationsModelChanged)
    Q_PROPERTY(bool filterTouchApps READ filterTouchApps WRITE setFilterTouchApps NOTIFY filterTouchAppsChanged)
    Q_PROPERTY(bool filterLegacyApps READ filterLegacyApps WRITE setFilterLegacyApps NOTIFY filterLegacyAppsChanged)

public:
    ApplicationsFilterModel(QObject *parent = 0);

    ApplicationManagerInterface* applicationsModel() const;
    void setApplicationsModel(ApplicationManagerInterface* applicationsModel);

    bool filterTouchApps() const;
    void setFilterTouchApps(bool filterTouchApps);

    bool filterLegacyApps() const;
    void setFilterLegacyApps(bool filterLegacyApps);

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

Q_SIGNALS:
    void applicationsModelChanged();
    void filterTouchAppsChanged();
    void filterLegacyAppsChanged();

private:
    ApplicationManagerInterface* m_appModel;
    bool m_filterTouchApps;
    bool m_filterLegacyApps;
};

#endif
