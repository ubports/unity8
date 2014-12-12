#include "asadapter.h"
#include "launcheritem.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QDebug>

ASAdapter::ASAdapter()
{
    m_accounts = new AccountsServiceDBusAdaptor();
    m_user = qgetenv("USER");
    if (m_user.isEmpty()) {
        qWarning() << "$USER not valid. Account Service integration will not work.";
    }
}

ASAdapter::~ASAdapter()
{
    m_accounts->deleteLater();
}

void ASAdapter::syncItems(QList<LauncherItem *> m_list)
{
    qDebug() << "syncing items to AS" << m_list.count();
    if (m_accounts && !m_user.isEmpty()) {
        QList<QVariantMap> items;

        Q_FOREACH(LauncherItem *item, m_list) {
            items << itemToVariant(item);
        }

        m_accounts->setUserPropertyAsync(m_user, "com.canonical.unity.AccountsService", "launcher-items", QVariant::fromValue(items));
    }
}

QVariantMap ASAdapter::itemToVariant(LauncherItem *item) const
{
    QVariantMap details;
    details.insert("id", item->appId());
    details.insert("name", item->name());
    details.insert("icon", item->icon());
    details.insert("count", item->count());
    details.insert("countVisible", item->countVisible());
    return details;
}
