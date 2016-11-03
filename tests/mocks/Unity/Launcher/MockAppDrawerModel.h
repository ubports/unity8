
#include <unity/shell/launcher/AppDrawerModelInterface.h>

#include "MockLauncherItem.h"

class MockAppDrawerModel: public AppDrawerModelInterface
{
    Q_OBJECT
public:
    MockAppDrawerModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    QList<MockLauncherItem*> m_list;
};
