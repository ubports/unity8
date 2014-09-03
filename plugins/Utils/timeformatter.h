/*
 * Copyright 2013 Canonical Ltd.
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
 * Author: Lars Uebernickel <lars.uebernickel@canonical.com>
 */

#ifndef TIME_FORMATTER_H
#define TIME_FORMATTER_H

#include <QObject>

// TODO - bug #1260728
class TimeFormatter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(QString timeString READ timeString NOTIFY timeStringChanged)
    Q_PROPERTY(qint64 time READ time WRITE setTime NOTIFY timeChanged)

public:
    TimeFormatter(QObject *parent = 0);
    virtual ~TimeFormatter();

    virtual QString format() const;
    QString timeString() const;
    qint64 time() const;

    void setFormat(const QString &format);
    void setTime(qint64 time);

    void update();

Q_SIGNALS:
    void formatChanged(const QString &format);
    void timeStringChanged(const QString &timeString);
    void timeChanged(qint64 time);

protected:
    TimeFormatter(const QString &initialFormat, QObject *parent = 0);

    virtual QString formatTime() const;

private:
    struct TimeFormatterPrivate *priv;
};

class GDateTimeFormatter : public TimeFormatter
{
public:
    GDateTimeFormatter(QObject *parent = 0);

protected:
    virtual QString formatTime() const;
};

#endif
