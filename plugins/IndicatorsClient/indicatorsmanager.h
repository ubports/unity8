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

#include "indicatorclientinterface.h"

class IndicatorsFactory;

class IndicatorsManager : public QObject
{
    Q_OBJECT
public:
    explicit IndicatorsManager(QObject* parent = 0);
    ~IndicatorsManager();

    Q_INVOKABLE void load();
    Q_INVOKABLE void unload();

    IndicatorClientInterface::Ptr indicator(const QString& indicator);

    QList<IndicatorClientInterface::Ptr> indicators();

Q_SIGNALS:
    void loaded(const QString& indicator);
    void aboutToBeUnloaded(const QString& indicator);

private Q_SLOTS:
    void onDirectoryChanged(const QString& direcory);
    void onFileChanged(const QString& file);

private:
    void load(const QDir& dir);
    void load(const QFileInfo& file);
    void unload(const QFileInfo& dir);

    void startVerify(const QString& path);
    void endVerify(const QString& path);

    class IndicatorData;
    QHash<QString, IndicatorData*> m_indicatorsData;
    QSharedPointer<QFileSystemWatcher> m_fsWatcher;
    IndicatorsFactory* m_factory;
};

#endif // INDICATORS_MANAGER_H
