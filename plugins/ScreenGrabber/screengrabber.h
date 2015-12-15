/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#ifndef SNAPSHOTTER_H
#define SNAPSHOTTER_H

#include <QObject>
#include <QString>
#include <QtConcurrent>

class ScreenGrabber: public QObject
{
    Q_OBJECT

public:
    explicit ScreenGrabber(QObject *parent = 0);
    ~ScreenGrabber() = default;

public Q_SLOTS:
    void captureAndSave(int angle = 0);

Q_SIGNALS:
    void screenshotSaved(const QString &filename);

private Q_SLOTS:
    void onScreenshotSaved();

private:
    QString makeFileName() const;
    QString getFormat() const;
    QString fileNamePrefix;
    int screenshotQuality = -1; // default quality for the format
    QFutureWatcher<QString> m_watcher;
};

#endif
