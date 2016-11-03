
#include <unity/shell/launcher/AppDrawerModelInterface.h>

#include "launcheritem.h"

class AppDrawerModel: public AppDrawerModelInterface
{
    Q_OBJECT
public:
    AppDrawerModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    QList<LauncherItem*> m_list;
};
