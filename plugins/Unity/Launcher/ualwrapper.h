#include <QObject>

class UalWrapper: public QObject
{
    Q_OBJECT
public:
    struct AppInfo {
        bool valid = false;
        QString name;
        QString icon;
    };

    UalWrapper(QObject* parent = nullptr);

    static QStringList installedApps();
    static AppInfo getApplicationInfo(const QString &appId);

};
