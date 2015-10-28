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
