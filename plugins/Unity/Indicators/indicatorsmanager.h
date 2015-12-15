/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef INDICATORS_MANAGER_H
#define INDICATORS_MANAGER_H

#include "indicator.h"
#include "unityindicatorsglobal.h"
#include "../Platform/platform.h"

#include <QObject>
#include <QFileSystemWatcher>
#include <QDir>
#include <QHash>
#include <QSharedPointer>

class UNITYINDICATORS_EXPORT IndicatorsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loaded READ isLoaded NOTIFY loadedChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY profileChanged)
public:
    explicit IndicatorsManager(QObject* parent = nullptr);
    ~IndicatorsManager();

    Q_INVOKABLE void load();
    Q_INVOKABLE void unload();

    QString profile() const;
    void setProfile(const QString& profile);

    Indicator::Ptr indicator(const QString& indicator_name);

    QVector<Indicator::Ptr> indicators();

    bool isLoaded() const;

Q_SIGNALS:
    void loadedChanged(bool);
    void profileChanged(const QString&);

    void indicatorLoaded(const QString& indicator_name);
    void indicatorAboutToBeUnloaded(const QString& indicator_name);

private Q_SLOTS:
    void onDirectoryChanged(const QString& directory);
    void onFileChanged(const QString& file);

private:
    void loadDir(const QDir& dir);
    void loadFile(const QFileInfo& file);
    void unloadFile(const QFileInfo& dir);

    void startVerify(const QString& path);
    void endVerify(const QString& path);

    void setLoaded(bool);

    class IndicatorData;
    QHash<QString, IndicatorData*> m_indicatorsData;
    QSharedPointer<QFileSystemWatcher> m_fsWatcher;
    bool m_loaded;
    QString m_profile;

    Platform m_platform;
};

#endif // INDICATORS_MANAGER_H
