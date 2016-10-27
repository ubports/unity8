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
 * Author: Pete Woods <pete.woods@canonical.com>
 */

#ifndef UNITY_MOCK_USERMETRICS_H
#define UNITY_MOCK_USERMETRICS_H

#include "ColorTheme.h"
#include <QtCore/QAbstractListModel>
#include <QtCore/QString>
#include <QtGui/QColor>

namespace UserMetricsOutput
{
class UserMetricsPrivate;

class Q_DECL_EXPORT UserMetrics: public QObject
{
Q_OBJECT

Q_PROPERTY(QString label READ label NOTIFY labelChanged FINAL)
Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged FINAL)
Q_PROPERTY(UserMetricsOutput::ColorTheme* firstColor READ firstColor NOTIFY firstColorChanged FINAL)
Q_PROPERTY(UserMetricsOutput::ColorTheme* secondColor READ secondColor NOTIFY secondColorChanged FINAL)
Q_PROPERTY(QAbstractItemModel *firstMonth READ firstMonth NOTIFY firstMonthChanged FINAL)
Q_PROPERTY(QAbstractItemModel *secondMonth READ secondMonth NOTIFY secondMonthChanged FINAL)
Q_PROPERTY(int currentDay READ currentDay NOTIFY currentDayChanged FINAL)

public:
    static UserMetrics *getInstance();

    ~UserMetrics();

    QString label() const;

    QString username() const;

    void setUsername(const QString &username);

    ColorTheme * firstColor() const;

    QAbstractItemModel *firstMonth() const;

    int currentDay() const;

    ColorTheme * secondColor() const;

    QAbstractItemModel *secondMonth() const;

    Q_INVOKABLE void reset();

Q_SIGNALS:
    void labelChanged(const QString &label);

    void usernameChanged(const QString &username);

    void firstColorChanged(ColorTheme *color);

    void firstMonthChanged(QAbstractItemModel *firstMonth);

    void currentDayChanged(int length);

    void secondColorChanged(ColorTheme *color);

    void secondMonthChanged(QAbstractItemModel *secondMonth);

    void nextDataSource();

    void readyForDataChange();

    void dataAboutToAppear();

    void dataAppeared();

    void dataAboutToChange();

    void dataChanged();

    void dataAboutToDisappear();

    void dataDisappeared();

protected Q_SLOTS:
    void nextDataSourceSlot();

    void readyForDataChangeSlot();

protected:
    UserMetricsPrivate * const d_ptr;

    explicit UserMetrics(QObject *parent = 0);

    Q_DISABLE_COPY(UserMetrics)
    Q_DECLARE_PRIVATE(UserMetrics)

};

}

#endif // UNITY_MOCK_USERMETRICS_H
