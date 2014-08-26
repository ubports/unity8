#include "launcheritem.h"

#include <QDBusVirtualObject>

class LauncherModel;

class DBusInterface: public QDBusVirtualObject
{
    Q_OBJECT
public:
    DBusInterface(LauncherModel *parent);
    ~DBusInterface();

    // QDBusVirtualObject implementaition
    QString introspect (const QString &path) const override;
    bool handleMessage(const QDBusMessage& message, const QDBusConnection& connection) override;

Q_SIGNALS:
    void countChanged(const QString &appId, int count);
    void countVisibleChanged(const QString &appId, bool countVisible);
    void refreshCalled();

private:
    static QString decodeAppId(const QString& path);
    static QString encodeAppId(const QString& appId);

    void emitPropChangedDbus(const QString& appId, const QString& property, const QVariant &value);

    LauncherModel *m_launcherModel;

};
