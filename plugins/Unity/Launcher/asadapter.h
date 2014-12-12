#ifndef ASADAPTER_H
#define ASADAPTER_H

#include <QVariantMap>

class LauncherItem;
class AccountsServiceDBusAdaptor;
class QDBusInterface;

class ASAdapter
{
public:
    ASAdapter();
    ~ASAdapter();

    void syncItems(QList<LauncherItem*> m_list);

private:
    QVariantMap itemToVariant(LauncherItem *item) const;

private:
    AccountsServiceDBusAdaptor *m_accounts;
    QString m_user;

    QDBusInterface *m_userInterface;

    friend class LauncherModelTest;
};

#endif
