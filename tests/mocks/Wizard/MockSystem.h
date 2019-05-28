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

#ifndef WIZARD_MOCK_SYSTEM_H
#define WIZARD_MOCK_SYSTEM_H

#include <QObject>
#include <QString>

class MockSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wizardEnabled READ wizardEnabled WRITE setWizardEnabled NOTIFY wizardEnabledChanged)
    Q_PROPERTY(bool isUpdate READ isUpdate WRITE setIsUpdate NOTIFY isUpdateChanged)

public:
    MockSystem();

    bool wizardEnabled() const;
    void setWizardEnabled(bool enabled);
    bool isUpdate() const;
    void setIsUpdate(bool enabled); // only in mock

public Q_SLOTS:
    void updateSessionLocale(const QString &locale);
    /**
     * Mark the wizard to skip all the pages and just show the last (welcome to ubuntu) page
     */
    void skipUntilFinishedPage();

Q_SIGNALS:
    void wizardEnabledChanged();
    void isUpdateChanged(); // only in mock
    void updateSessionLocaleCalled(const QString &locale); // only in mock
    void wouldHaveSetSkipUntilFinish(); // only in mock

private:
    Q_DISABLE_COPY(MockSystem)

    bool m_wizardEnabled = true;
    bool m_isUpdate = false;
};

#endif
