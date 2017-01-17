/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef CONSOLELOG_H
#define CONSOLELOG_H

#include <QThread>
#include <QMutex>
#include <QSet>

class ConsoleLog;

class LogRedirector : public QThread
{
    Q_OBJECT
public:
    static LogRedirector *instance();

    void add(ConsoleLog* logger);
    void remove(ConsoleLog* logger);

private Q_SLOTS:
    void checkLog();

Q_SIGNALS:
    void log(QString log);

private:
    LogRedirector();
    void run() Q_DECL_OVERRIDE;

    QMutex m_mutex;
    int m_pipe[2];
    int m_ref;
    bool m_stop;

    enum PIPES { READ, WRITE };
};

class ConsoleLog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString out READ out NOTIFY outChanged)
    Q_PROPERTY(int maxLines READ maxLines WRITE setMaxLines NOTIFY maxLinesChanged)
public:
    explicit ConsoleLog(QObject *parent = 0);
    ~ConsoleLog();

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    QString out() const;

    int maxLines() const { return m_maxLines; }
    void setMaxLines(int maxLines);

public Q_SLOTS:
    void logged(QString captured);

Q_SIGNALS:
    void enabledChanged();
    void outChanged();
    void maxLinesChanged();

private:
    void updateEnabled();

    QStringList m_out;
    bool m_enabled;
    int m_maxLines;
};

#endif // CONSOLELOG_H
