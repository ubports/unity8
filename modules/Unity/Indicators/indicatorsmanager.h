/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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
 */


#ifndef INDICATORS_MANAGER_H
#define INDICATORS_MANAGER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QDir>
#include <QHash>
#include <QSharedPointer>

#include "indicator.h"

class IndicatorsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loaded READ isLoaded NOTIFY loadedChanged)
public:
    explicit IndicatorsManager(QObject* parent = 0);
    ~IndicatorsManager();

    Q_INVOKABLE void load();
    Q_INVOKABLE void unload();

    Indicator::Ptr indicator(const QString& indicator);

    QList<Indicator::Ptr> indicators();

    bool isLoaded() const;

Q_SIGNALS:
    void loadedChanged(bool);

    void indicatorLoaded(const QString& indicator);
    void indicatorAboutToBeUnloaded(const QString& indicator);

private Q_SLOTS:
    void onDirectoryChanged(const QString& direcory);
    void onFileChanged(const QString& file);

private:
    void load(const QDir& dir);
    void load(const QFileInfo& file);
    void unload(const QFileInfo& dir);

    void startVerify(const QString& path);
    void endVerify(const QString& path);

    void setLoaded(bool);

    class IndicatorData;
    QHash<QString, IndicatorData*> m_indicatorsData;
    QSharedPointer<QFileSystemWatcher> m_fsWatcher;
    bool m_loaded;
};

#endif // INDICATORS_MANAGER_H
