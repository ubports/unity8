#ifndef GSETTINGS_H
#define GSETTINGS_H

#include <QObject>
#include <QStringList>


class GSettings: public QObject
{
    Q_OBJECT
public:
    GSettings(QObject *parent = nullptr);

    QStringList storedApplications() const;
    void setStoredApplications(const QStringList &storedApplications);
};

#endif
