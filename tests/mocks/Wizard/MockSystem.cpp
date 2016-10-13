/*
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDebug>
#include <QSettings>

#include "MockSystem.h"

MockSystem::MockSystem()
    : QObject(),
      m_wizardEnabled(false)
{
}

bool MockSystem::wizardEnabled() const
{
    return m_wizardEnabled;
}

void MockSystem::setWizardEnabled(bool enabled)
{
    m_wizardEnabled = enabled;
    Q_EMIT wizardEnabledChanged();
}

void MockSystem::updateSessionLocale(const QString &locale)
{
    Q_EMIT updateSessionLocaleCalled(locale);
}

void MockSystem::skipUntilFinishedPage()
{
    QSettings settings;
    settings.setValue(QStringLiteral("Wizard/SkipUntilFinishedPage"), true);
    settings.sync();
}
