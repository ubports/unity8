#include "desktopfilehandler.h"

#include <QStringList>
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QDebug>

DesktopFileHandler::DesktopFileHandler(QObject *parent):
    QObject(parent)
{

}

QString DesktopFileHandler::findDesktopFile(const QString &appId) const
{
    int dashPos = -1;
    QString helper = appId;

    QStringList searchDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
#ifdef LAUNCHER_TESTING
    searchDirs << "";
#endif

    QString path;
    do {
        if (dashPos != -1) {
            helper.replace(dashPos, 1, '/');
        }

        if (helper.contains("/")) {
            path += helper.split('/').first() + '/';
            helper.remove(QRegExp("^" + path));
        }

        Q_FOREACH(const QString &searchDirName, searchDirs) {
            QDir searchDir(searchDirName + "/" + path);
            Q_FOREACH(const QString &desktopFile, searchDir.entryList(QStringList() << "*.desktop")) {
                if (desktopFile.startsWith(helper)) {
                    QFileInfo fileInfo(searchDir, desktopFile);
                    return fileInfo.absoluteFilePath();
                }
            }
        }

        dashPos = helper.indexOf("-");
    } while (dashPos != -1);

    return QString();
}

QString DesktopFileHandler::displayName(const QString &appId) const
{
    QString desktopFile = findDesktopFile(appId);
    if (desktopFile.isEmpty()) {
        return QString();
    }

    QSettings settings(desktopFile, QSettings::IniFormat);
    return settings.value("Desktop Entry/Name").toString();
}

QString DesktopFileHandler::icon(const QString &appId) const
{
    QString desktopFile = findDesktopFile(appId);
    if (desktopFile.isEmpty()) {
        return QString();
    }

    QSettings settings(desktopFile, QSettings::IniFormat);
    QString iconString = settings.value("Desktop Entry/Icon").toString();
    QString pathString = settings.value("Desktop Entry/Path").toString();
    qDebug() << "checking icon" << iconString << pathString << desktopFile;
    qDebug() << settings.allKeys();
    if (QFileInfo(iconString).exists()) {
        return QFileInfo(iconString).absoluteFilePath();
    } else if (QFileInfo(pathString + '/' + iconString).exists()) {
        return pathString + '/' + iconString;
    }
    return "image://theme/" + iconString;
}
