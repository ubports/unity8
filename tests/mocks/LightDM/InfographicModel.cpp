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

#include "InfographicModelPrivate.h"
#include "InfographicModel.h"

#include <QtCore/QDir>
#include <QtCore/QString>
#include <QtGui/QIcon>
#include <QMultiMap>

using namespace QLightDM;

namespace QLightDM
{

class InfographicColorThemePrivate: QObject
{
public:
    explicit InfographicColorThemePrivate(InfographicColorTheme *parent = 0);

    InfographicColorThemePrivate(const QColor &start, const QColor &main,
            const QColor &end, InfographicColorTheme *parent = 0);

    ~InfographicColorThemePrivate();

    InfographicColorTheme * const q_ptr;

    QColor m_start;

    QColor m_main;

    QColor m_end;

protected:
    int calculateLength();

private:
    Q_DECLARE_PUBLIC(InfographicColorTheme)
};

class InfographicDataPrivate: QObject
{
public:
    explicit InfographicDataPrivate(InfographicData *parent);

    InfographicDataPrivate(const QString &label,
            const InfographicColorTheme &firstColor,
            const QVariantList &firstMonth,
            const InfographicColorTheme &secondColor,
            const QVariantList &secondMonth, InfographicData *parent);

    ~InfographicDataPrivate();

    InfographicData * const q_ptr;
    QString m_label;
    InfographicColorTheme m_firstColor;
    QVariantList m_firstMonth;
    InfographicColorTheme m_secondColor;
    QVariantList m_secondMonth;
    int m_length;

protected:
    int calculateLength();

private:
    Q_DECLARE_PUBLIC(InfographicData)
};

}

InfographicColorThemePrivate::InfographicColorThemePrivate(
        InfographicColorTheme *parent) :
        q_ptr(parent)
{
}

InfographicColorThemePrivate::InfographicColorThemePrivate(const QColor &start,
        const QColor &main, const QColor &end, InfographicColorTheme *parent) :
        q_ptr(parent), m_start(start), m_main(main), m_end(end)
{
}

InfographicColorThemePrivate::~InfographicColorThemePrivate()
{
}

InfographicColorTheme::InfographicColorTheme(QObject *parent) :
        QObject(parent), d_ptr(new InfographicColorThemePrivate(this))
{
}

InfographicColorTheme::InfographicColorTheme(QColor &first, QColor &main,
        QColor &end, QObject *parent) :
        QObject(parent), d_ptr(
                new InfographicColorThemePrivate(first, main, end, this))
{

}

InfographicColorTheme & InfographicColorTheme::operator=(
        const InfographicColorTheme & other)
{
    if (d_ptr->m_start != other.d_ptr->m_start)
    {
        d_ptr->m_start = other.d_ptr->m_start;
        startChanged(d_ptr->m_start);
    }
    if (d_ptr->m_main != other.d_ptr->m_main)
    {
        d_ptr->m_main = other.d_ptr->m_main;
        mainChanged(d_ptr->m_main);
    }

    if (d_ptr->m_end != other.d_ptr->m_end)
    {
        d_ptr->m_end = other.d_ptr->m_end;
        endChanged(d_ptr->m_end);
    }

    return *this;
}

InfographicColorTheme::~InfographicColorTheme()
{
    delete d_ptr;
}

QColor InfographicColorTheme::start() const
{
    return d_ptr->m_start;
}

QColor InfographicColorTheme::main() const
{
    return d_ptr->m_main;
}

QColor InfographicColorTheme::end() const
{
    return d_ptr->m_end;
}

InfographicDataPrivate::InfographicDataPrivate(InfographicData *parent) :
        q_ptr(parent), m_firstColor(this), m_secondColor(this)
{
    m_length = calculateLength();
}

InfographicDataPrivate::InfographicDataPrivate(const QString &label,
        const InfographicColorTheme &firstColor, const QVariantList &firstMonth,
        const InfographicColorTheme &secondColor,
        const QVariantList &secondMonth, InfographicData *parent) :
        q_ptr(parent), m_label(label), m_firstColor(this), m_firstMonth(
                firstMonth), m_secondColor(this), m_secondMonth(secondMonth)
{
    m_length = calculateLength();
    m_firstColor = firstColor;
    m_secondColor = secondColor;
}

InfographicDataPrivate::~InfographicDataPrivate()
{
}

int InfographicDataPrivate::calculateLength()
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

InfographicData::InfographicData(QObject *parent) :
        QObject(parent), d_ptr(new InfographicDataPrivate(this))
{
}

InfographicData::InfographicData(const QString &label,
        const InfographicColorTheme &firstColor, const QVariantList &firstMonth,
        const InfographicColorTheme &secondColor,
        const QVariantList &secondMonth, QObject* parent) :
        QObject(parent), d_ptr(
                new InfographicDataPrivate(label, firstColor, firstMonth,
                        secondColor, secondMonth, this))
{
}

InfographicData::~InfographicData()
{
    delete d_ptr;
}

const QString & InfographicData::label() const
{
    return d_ptr->m_label;
}

const InfographicColorTheme & InfographicData::firstColor() const
{
    return d_ptr->m_firstColor;
}

const QVariantList & InfographicData::firstMonth() const
{
    return d_ptr->m_firstMonth;
}

const InfographicColorTheme & InfographicData::secondColor() const
{
    return d_ptr->m_secondColor;
}

const QVariantList & InfographicData::secondMonth() const
{
    return d_ptr->m_secondMonth;
}

int InfographicData::length() const
{
    return d_ptr->m_length;
}

InfographicModelPrivate::InfographicModelPrivate(InfographicModel *parent) :
        q_ptr(parent), m_currentDay(0)
{
    m_fakeData.insert("", InfographicDataPtr(new InfographicData(this)));
}

InfographicModelPrivate::~InfographicModelPrivate()
{
}

void InfographicModelPrivate::setUsername(const QString &username)
{
    if(m_username == username) {
        return;
    }

    m_username = username;

    m_dataIndex = m_fakeData.constFind(m_username);
    if (m_dataIndex == m_fakeData.end())
    {
        m_dataIndex = m_fakeData.constFind("");
    }

    loadFakeData();

    q_ptr->usernameChanged(m_username);
}

void InfographicModelPrivate::loadFakeData()
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

void InfographicModelPrivate::finishSetFakeData()
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

void InfographicModelPrivate::nextFakeData()
{
    ++m_dataIndex;
    if (m_dataIndex == m_fakeData.end() || m_dataIndex.key() != m_username)
    {
        m_dataIndex = m_fakeData.constFind(m_username);
    }

    loadFakeData();
}

InfographicModel::InfographicModel(QObject *parent) :
        QObject(parent), d_ptr(new InfographicModelPrivate(this))
{
    d_ptr->generateFakeData();
    setUsername("");

    connect(this, SIGNAL(nextDataSource()), this, SLOT(nextDataSourceSlot()),
            Qt::QueuedConnection);
    connect(this, SIGNAL(readyForDataChange()), this,
            SLOT(readyForDataChangeSlot()), Qt::QueuedConnection);
}

InfographicModel::~InfographicModel()
{
    delete d_ptr;
}

QString InfographicModel::label() const
{
    return d_ptr->m_label;
}

QString InfographicModel::username() const
{
    return d_ptr->m_username;
}

void InfographicModel::setUsername(const QString &username)
{
    d_ptr->setUsername(username);
}

InfographicColorTheme * InfographicModel::firstColor() const
{
    return &d_ptr->m_firstColor;
}

InfographicColorTheme * InfographicModel::secondColor() const
{
    return &d_ptr->m_secondColor;
}

QAbstractItemModel * InfographicModel::firstMonth() const
{
    return &d_ptr->m_firstMonth;
}

QAbstractItemModel * InfographicModel::secondMonth() const
{
    return &d_ptr->m_secondMonth;
}

int InfographicModel::currentDay() const
{
    return d_ptr->m_currentDay;
}

void InfographicModel::nextDataSourceSlot()
{
    d_ptr->nextFakeData();
}

void InfographicModel::readyForDataChangeSlot()
{
    d_ptr->finishSetFakeData();
}

/**
 * Factory methods
 */

InfographicModel * InfographicModel::getInstance()
{
    return new InfographicModel();
}
