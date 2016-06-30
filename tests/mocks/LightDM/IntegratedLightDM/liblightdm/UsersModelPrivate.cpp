/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#include "UsersModelPrivate.h"
#include "UsersModel.h"

namespace QLightDM
{

UsersModelPrivate::UsersModelPrivate(UsersModel* parent)
  : mockMode("single")
  , q_ptr(parent)
{
    char *envMockMode = getenv("LIBLIGHTDM_MOCK_MODE");
    if (envMockMode) {
        mockMode = envMockMode;
    }
    resetEntries();
}

void UsersModelPrivate::resetEntries()
{
    Q_Q(UsersModel);

    q->beginResetModel();

    if (mockMode == "single") {
        resetEntries_single();
    } else if (mockMode == "single-passphrase") {
        resetEntries_singlePassphrase();
    } else if (mockMode == "single-pin") {
        resetEntries_singlePin();
    } else if (mockMode == "full") {
        resetEntries_full();
    }

    // Assign uids in a loop, just to avoid having to muck with them when
    // adding or removing test users.
    for (int i = 0; i < entries.size(); i++) {
        entries[i].uid = i + 1;
    }

    q->endResetModel();
}

void UsersModelPrivate::resetEntries_single()
{
    entries =
    {
        { "single", "Single User", 0, 0, false, false, "ubuntu", 0 },
    };
}

void UsersModelPrivate::resetEntries_singlePassphrase()
{
    entries =
    {
        { "single", "Single User", 0, 0, false, false, "ubuntu", 0 },
    };
}

void UsersModelPrivate::resetEntries_singlePin()
{
    entries =
    {
        { "has-pin", "Has PIN", 0, 0, false, false, "ubuntu", 0 },
    };
}

void UsersModelPrivate::resetEntries_full()
{
    entries =
    {
        { "has-password",      "Has Password", 0, 0, false, false, "ubuntu", 0 },
        { "has-pin",           "Has PIN",      0, 0, false, false, "ubuntu", 0 },
        { "different-prompt",  "Different Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "no-password",       "No Password", 0, 0, false, false, "ubuntu", 0 },
        { "auth-error",        "Auth Error", 0, 0, false, false, "ubuntu", 0 },
        { "two-factor",        "Two Factor", 0, 0, false, false, "ubuntu", 0 },
        { "info-prompt",       "Info Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "html-info-prompt",  "HTML Info Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "long-info-prompt",  "Long Info Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "wide-info-prompt",  "Wide Info Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "multi-info-prompt", "Multi Info Prompt", 0, 0, false, false, "ubuntu", 0 },
        { "long-name",         "Long name (far far too long to fit, seriously this would never fit on the screen, you will never see this part of the name)", 0, 0, false, false, "ubuntu", 0 },
        { "color-background",  "Color Background", "#dd4814", 0, false, false, "ubuntu", 0 },
        // white and black are a bit redundant, but useful for manually testing if UI is still readable
        { "white-background",  "White Background", "#ffffff", 0, false, false, "ubuntu", 0 },
        { "black-background",  "Black Background", "#000000", 0, false, false, "ubuntu", 0 },
        { "no-background",     "No Background", "", 0, false, false, "ubuntu", 0 },
        { "unicode",           "가나다라마", 0, 0, false, false, "ubuntu", 0 },
        { "no-response",       "No Response", 0, 0, false, false, "ubuntu", 0 },
        { "empty-name",        "", 0, 0, false, false, "ubuntu", 0 },
    };
}

} // namespace QLightDM
