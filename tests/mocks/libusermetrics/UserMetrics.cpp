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

#include "UserMetrics.h"
#include <qvariantlistmodel.h>

#include <QtCore/QDir>
#include <QtCore/QString>
#include <QtGui/QIcon>
#include <QMultiMap>

#include <functional>
#include <random>

using namespace UserMetricsOutput;

namespace UserMetricsOutput
{
class UserMetricsDataPrivate;
class UserMetricsPrivate;

class Q_DECL_EXPORT UserMetricsData: public QObject
{
public:
    explicit UserMetricsData(QObject *parent);

    UserMetricsData(const QString &label,
            const ColorTheme &firstColor,
            const QVariantList &firstMonth,
            const ColorTheme &secondColor,
            const QVariantList &secondMonth, QObject* parent);

    ~UserMetricsData();

protected:
    UserMetricsDataPrivate * const d_ptr;

public:
    const QString & label() const;
    const ColorTheme & firstColor() const;
    const QVariantList & firstMonth() const;
    const ColorTheme & secondColor() const;
    const QVariantList & secondMonth() const;
    int length() const;

private:
    Q_DECLARE_PRIVATE(UserMetricsData)
};

class UserMetricsPrivate: QObject
{
public:
    explicit UserMetricsPrivate(UserMetrics *parent);

    ~UserMetricsPrivate();

public:
    typedef QSharedPointer<UserMetricsData> UserMetricsDataPtr;
    typedef QMultiMap<QString, UserMetricsDataPtr> FakeDataMap;

    UserMetrics * const q_ptr;
    QString m_label;
    ColorTheme m_firstColor;
    QVariantListModel m_firstMonth;
    ColorTheme m_secondColor;
    QVariantListModel m_secondMonth;
    int m_currentDay;
    QString m_username;
    FakeDataMap::const_iterator m_dataIndex;
    UserMetricsDataPtr m_newData;
    FakeDataMap m_fakeData;

    void setUsername(const QString &username);

protected:
    void nextFakeData();

    void generateFakeData();

    void loadFakeData();

    void finishSetFakeData();

private:
    Q_DECLARE_PUBLIC(UserMetrics)
};

class UserMetricsDataPrivate: QObject
{
public:
    explicit UserMetricsDataPrivate(UserMetricsData *parent);

    UserMetricsDataPrivate(const QString &label,
            const ColorTheme &firstColor,
            const QVariantList &firstMonth,
            const ColorTheme &secondColor,
            const QVariantList &secondMonth, UserMetricsData *parent);

    ~UserMetricsDataPrivate();

    UserMetricsData * const q_ptr;
    QString m_label;
    ColorTheme m_firstColor;
    QVariantList m_firstMonth;
    ColorTheme m_secondColor;
    QVariantList m_secondMonth;
    int m_length;

protected:
    int calculateLength();

private:
    Q_DECLARE_PUBLIC(UserMetricsData)
};

}

UserMetricsDataPrivate::UserMetricsDataPrivate(UserMetricsData *parent) :
        q_ptr(parent), m_firstColor(this), m_secondColor(this)
{
    m_length = calculateLength();
}

UserMetricsDataPrivate::UserMetricsDataPrivate(const QString &label,
        const ColorTheme &firstColor, const QVariantList &firstMonth,
        const ColorTheme &secondColor,
        const QVariantList &secondMonth, UserMetricsData *parent) :
        q_ptr(parent), m_label(label), m_firstColor(this), m_firstMonth(
                firstMonth), m_secondColor(this), m_secondMonth(secondMonth)
{
    m_length = calculateLength();
    m_firstColor = firstColor;
    m_secondColor = secondColor;
}

UserMetricsDataPrivate::~UserMetricsDataPrivate()
{
}

int UserMetricsDataPrivate::calculateLength()
{
    int day(m_firstMonth.size());
    auto it = m_firstMonth.end(), end = m_firstMonth.begin();
    while (it != end)
    {
        --it;
        --day;
        if (!it->isNull())
        {
            return day;
        }
    }

    return -1;
}

UserMetricsData::UserMetricsData(QObject *parent) :
        QObject(parent), d_ptr(new UserMetricsDataPrivate(this))
{
}

UserMetricsData::UserMetricsData(const QString &label,
        const ColorTheme &firstColor, const QVariantList &firstMonth,
        const ColorTheme &secondColor,
        const QVariantList &secondMonth, QObject* parent) :
        QObject(parent), d_ptr(
                new UserMetricsDataPrivate(label, firstColor, firstMonth,
                        secondColor, secondMonth, this))
{
}

UserMetricsData::~UserMetricsData()
{
    delete d_ptr;
}

const QString & UserMetricsData::label() const
{
    return d_ptr->m_label;
}

const ColorTheme & UserMetricsData::firstColor() const
{
    return d_ptr->m_firstColor;
}

const QVariantList & UserMetricsData::firstMonth() const
{
    return d_ptr->m_firstMonth;
}

const ColorTheme & UserMetricsData::secondColor() const
{
    return d_ptr->m_secondColor;
}

const QVariantList & UserMetricsData::secondMonth() const
{
    return d_ptr->m_secondMonth;
}

int UserMetricsData::length() const
{
    return d_ptr->m_length;
}

UserMetricsPrivate::UserMetricsPrivate(UserMetrics *parent) :
        q_ptr(parent), m_firstColor(this), m_secondColor(this)
{
    m_fakeData.insert("", UserMetricsDataPtr(new UserMetricsData(this)));
}

UserMetricsPrivate::~UserMetricsPrivate()
{
}

void UserMetricsPrivate::setUsername(const QString &username)
{
    if (m_username == username && m_newData) {
        return;
    }

    m_username = username;

    m_dataIndex = m_fakeData.constFind(m_username);
    if (m_dataIndex == m_fakeData.constEnd())
    {
        m_dataIndex = m_fakeData.constFind("");
    }

    loadFakeData();

    q_ptr->usernameChanged(m_username);
}

void UserMetricsPrivate::generateFakeData()
{
    std::default_random_engine generator;
    std::normal_distribution<qreal> distribution(0.5, 0.2);
    auto rand = std::bind(distribution, generator);

    QVector<QColor> colours;
    colours.push_back(QColor::fromRgbF(0.3, 0.27, 0.32));
    colours.push_back(QColor::fromRgbF(0.83, 0.49, 0.58));
    colours.push_back(QColor::fromRgbF(0.63, 0.51, 0.59));

    colours.push_back(QColor::fromRgbF(0.28, 0.26, 0.4));
    colours.push_back(QColor::fromRgbF(0.47, 0.38, 0.56));
    colours.push_back(QColor::fromRgbF(0.69, 0.65, 0.78));

    colours.push_back(QColor::fromRgbF(0.32, 0.21, 0.16));
    colours.push_back(QColor::fromRgbF(0.55, 0.45, 0.32));
    colours.push_back(QColor::fromRgbF(0.85, 0.74, 0.53));

    colours.push_back(QColor::fromRgbF(0.25, 0.31, 0.19));
    colours.push_back(QColor::fromRgbF(0.63, 0.53, 0.3));
    colours.push_back(QColor::fromRgbF(0.89, 0.56, 0.31));

    ColorTheme first(colours[0], colours[1], colours[2]);
    ColorTheme second(colours[3], colours[4], colours[5]);
    ColorTheme eighth(colours[6], colours[7], colours[8]);
    ColorTheme ninth(colours[9], colours[10], colours[11]);

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<UserMetricsData> data(
                new UserMetricsData("<b>52km</b> travelled", first, firstMonth,
                        ninth, secondMonth, this));
        m_fakeData.insert("single", data);
        m_fakeData.insert("has-pin", data);
    }

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<UserMetricsData> data(
                new UserMetricsData("<b>33</b> messages today", second,
                        firstMonth, eighth, secondMonth, this));
        m_fakeData.insert("single", data);
        m_fakeData.insert("has-pin", data);
    }

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        firstMonth[8] = QVariant(1.0); // oversized 9th day, to test clipping
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<UserMetricsData> data(
                new UserMetricsData("<b>19</b> minutes talk time", eighth,
                        firstMonth, second, secondMonth, this));
        m_fakeData.insert("single", data);
        m_fakeData.insert("has-pin", data);
        // Also use same data for some tablet users
        m_fakeData.insert("has-password", data);
        m_fakeData.insert("no-password", data);
        m_fakeData.insert("empty-name", data);
    }
}

void UserMetricsPrivate::loadFakeData()
{
    m_newData = *m_dataIndex;

    bool oldLabelEmpty = m_label.isEmpty();
    bool newLabelEmpty = m_newData->label().isEmpty();

    if (oldLabelEmpty && !newLabelEmpty)
    {
        q_ptr->dataAboutToAppear();
        finishSetFakeData();
    } else if (!oldLabelEmpty && newLabelEmpty)
    {
        q_ptr->dataAboutToDisappear();
    } else if (!oldLabelEmpty && !newLabelEmpty)
    {
        q_ptr->dataAboutToChange();
    }
    // we emit no signal if the data has stayed empty
}

void UserMetricsPrivate::finishSetFakeData()
{
    bool oldLabelEmpty = m_label.isEmpty();
    bool newLabelEmpty = m_newData->label().isEmpty();

    m_label = m_newData->label();
    m_firstColor = m_newData->firstColor();
    m_firstMonth.setVariantList(m_newData->firstMonth());
    m_secondColor = m_newData->secondColor();
    m_secondMonth.setVariantList(m_newData->secondMonth());

    bool currentDayChanged = m_currentDay != m_newData->length();
    m_currentDay = m_newData->length();

    q_ptr->labelChanged(m_label);
    if (currentDayChanged)
    {
        q_ptr->currentDayChanged(m_currentDay);
    }

    if (oldLabelEmpty && !newLabelEmpty)
    {
        q_ptr->dataAppeared();
    } else if (!oldLabelEmpty && newLabelEmpty)
    {
        q_ptr->dataDisappeared();
    } else if (!oldLabelEmpty && !newLabelEmpty)
    {
        q_ptr->dataChanged();
    }
    // we emit no signal if the data has stayed empty
}

void UserMetricsPrivate::nextFakeData()
{
    ++m_dataIndex;
    if (m_dataIndex == m_fakeData.constEnd() || m_dataIndex.key() != m_username)
    {
        m_dataIndex = m_fakeData.constFind(m_username);
        if (m_dataIndex == m_fakeData.constEnd())
        {
            m_dataIndex = m_fakeData.constFind("");
        }
    }

    loadFakeData();
}

UserMetrics::UserMetrics(QObject *parent) :
        QObject(parent), d_ptr(new UserMetricsPrivate(this))
{
    d_ptr->generateFakeData();
    setUsername("");

    connect(this, &UserMetrics::nextDataSource, this, &UserMetrics::nextDataSourceSlot, Qt::QueuedConnection);
    connect(this, &UserMetrics::readyForDataChange, this, &UserMetrics::readyForDataChangeSlot, Qt::QueuedConnection);
}

UserMetrics::~UserMetrics()
{
    delete d_ptr;
}

QString UserMetrics::label() const
{
    return d_ptr->m_label;
}

QString UserMetrics::username() const
{
    return d_ptr->m_username;
}

void UserMetrics::setUsername(const QString &username)
{
    d_ptr->setUsername(username);
}

ColorTheme *UserMetrics::firstColor() const
{
    return &d_ptr->m_firstColor;
}

ColorTheme *UserMetrics::secondColor() const
{
    return &d_ptr->m_secondColor;
}

QAbstractItemModel *UserMetrics::firstMonth() const
{
    return &d_ptr->m_firstMonth;
}

QAbstractItemModel *UserMetrics::secondMonth() const
{
    return &d_ptr->m_secondMonth;
}

int UserMetrics::currentDay() const
{
    return d_ptr->m_currentDay;
}

void UserMetrics::nextDataSourceSlot()
{
    d_ptr->nextFakeData();
}

void UserMetrics::readyForDataChangeSlot()
{
    d_ptr->finishSetFakeData();
}

/**
 * Factory methods
 */

UserMetrics * UserMetrics::getInstance()
{
    return new UserMetrics();
}
