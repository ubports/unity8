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

#ifndef LIGHTDM_INFOGRAPHICMODEL_H
#define LIGHTDM_INFOGRAPHICMODEL_H

#include <QtCore/QString>
#include <QtGui/qcolor.h>
#include <QAbstractListModel>

namespace QLightDM
{
class InfographicColorThemePrivate;

class Q_DECL_EXPORT InfographicColorTheme: public QObject
{
Q_OBJECT

Q_PROPERTY(QColor start READ start NOTIFY startChanged FINAL)
Q_PROPERTY(QColor main READ main NOTIFY mainChanged FINAL)
Q_PROPERTY(QColor end READ end NOTIFY endChanged FINAL)

public:
    explicit InfographicColorTheme(QObject *parent = 0);

    explicit InfographicColorTheme(QColor &first, QColor &main, QColor &end,
            QObject *parent = 0);

    InfographicColorTheme & operator=(const InfographicColorTheme & other);

    ~InfographicColorTheme();

    QColor start() const;

    QColor main() const;

    QColor end() const;

Q_SIGNALS:
    void startChanged(const QColor &color);

    void mainChanged(const QColor &color);

    void endChanged(const QColor &color);

protected:
    InfographicColorThemePrivate * const d_ptr;

    Q_DECLARE_PRIVATE(InfographicColorTheme)

};

class InfographicModelPrivate;

class Q_DECL_EXPORT InfographicModel: public QObject
{
Q_OBJECT

Q_PROPERTY(QString label READ label NOTIFY labelChanged FINAL)
Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged FINAL)
Q_PROPERTY(QLightDM::InfographicColorTheme* firstColor READ firstColor NOTIFY firstColorChanged FINAL)
Q_PROPERTY(QLightDM::InfographicColorTheme* secondColor READ secondColor NOTIFY secondColorChanged FINAL)
Q_PROPERTY(QAbstractItemModel *firstMonth READ firstMonth NOTIFY firstMonthChanged FINAL)
Q_PROPERTY(QAbstractItemModel *secondMonth READ secondMonth NOTIFY secondMonthChanged FINAL)
Q_PROPERTY(int currentDay READ currentDay NOTIFY currentDayChanged FINAL)

public:
    static InfographicModel *getInstance();

    explicit InfographicModel(QObject *parent = 0);
    ~InfographicModel();

    QString label() const;

    QString username() const;

    void setUsername(const QString &username);

    InfographicColorTheme * firstColor() const;

    QAbstractItemModel *firstMonth() const;

    int currentDay() const;

    InfographicColorTheme * secondColor() const;

    QAbstractItemModel *secondMonth() const;

Q_SIGNALS:
    void labelChanged(const QString &label);

    void usernameChanged(const QString &username);

    void firstColorChanged(InfographicColorTheme *color);

    void firstMonthChanged(QAbstractItemModel *firstMonth);

    void currentDayChanged(int length);

    void secondColorChanged(InfographicColorTheme *color);

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
    InfographicModelPrivate * const d_ptr;

    Q_DISABLE_COPY(InfographicModel)
    Q_DECLARE_PRIVATE(InfographicModel)

};

}

#endif // LIGHTDM_INFOGRAPHICMODEL_H
