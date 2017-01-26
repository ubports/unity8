/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "Greeter.h"
#include "PromptsModel.h"

#include <QtTest>

class GreeterPromptsModelTest : public QObject
{
    Q_OBJECT

private:
    class PromptInfo {
    public:
        PromptInfo(PromptsModel::PromptType t, const QString &p)
            : type(t), text(p) {}
        PromptsModel::PromptType type;
        QString text;
    };

    void selectUser(const QString &user)
    {
        Greeter::instance()->authenticate(user);
        QCOMPARE(Greeter::instance()->authenticationUser(), user);
    }

    void respond(const QString &response, bool authenticated)
    {
        Greeter::instance()->respond(response);
        QCOMPARE(Greeter::instance()->isAuthenticated(), authenticated);
    }

    void comparePrompts(const QList<PromptInfo> &expected)
    {
        QTRY_COMPARE(prompts->rowCount(), expected.size());
        for (int i = 0; i < prompts->rowCount(); i++) {
            QCOMPARE(prompts->data(prompts->index(i, 0), PromptsModel::TypeRole).toInt(), (int)expected[i].type);
            QCOMPARE(prompts->data(prompts->index(i, 0), PromptsModel::TextRole).toString(), expected[i].text);
        }
    }

private Q_SLOTS:

    void initTestCase()
    {
        prompts = Greeter::instance()->promptsModel();
        QVERIFY(prompts);
    }

    void init()
    {
        QCOMPARE(prompts->rowCount(), 0);
    }

    void cleanup()
    {
        prompts->clear();
    }

    void testSimpleFailure()
    {
        selectUser("has-password");
        comparePrompts({{PromptsModel::Secret, ""}});
        respond("nope", false);
        comparePrompts({{PromptsModel::Secret, ""}}); // prompts don't change immediately
        selectUser("has-password");
        comparePrompts({{PromptsModel::Error, "Invalid password, please try again"},
                        {PromptsModel::Secret, ""}});
    }

    void testSimpleSuccess()
    {
        selectUser("has-password");
        comparePrompts({{PromptsModel::Secret, ""}});
        respond("password", true);
        comparePrompts({{PromptsModel::Secret, ""}}); // prompts don't change
    }

    void testHasPassword()
    {
        selectUser("has-password");
        comparePrompts({{PromptsModel::Secret, ""}});
    }

    void testDifferentPrompt()
    {
        selectUser("different-prompt");
        comparePrompts({{PromptsModel::Secret, "Secret word"}});
    }

    void testNoPassword()
    {
        selectUser("no-password");
        comparePrompts({{PromptsModel::Button, "Log In"}});
    }

    void testAuthError()
    {
        selectUser("auth-error");
        comparePrompts({{PromptsModel::Error, "Failed to authenticate"},
                        {PromptsModel::Button, "Retry"}});
    }

    void testTwoFactor()
    {
        selectUser("two-factor");
        comparePrompts({{PromptsModel::Secret, ""}});
        respond("password", false);
        comparePrompts({{PromptsModel::Question, "otp"}});
    }

    void testTwoPrompts()
    {
        selectUser("two-prompts");
        comparePrompts({{PromptsModel::Question, "Favorite Color (blue)"},
                        {PromptsModel::Secret, ""}});
    }

    void testWackyPrompts()
    {
        selectUser("wacky-prompts");
        comparePrompts({{PromptsModel::Message, "First message"},
                        {PromptsModel::Question, "Favorite Color (blue)"},
                        {PromptsModel::Error, "Second message"},
                        {PromptsModel::Secret, ""},
                        {PromptsModel::Message, "Last message"}});
    }

    void testHtmlInfoPrompts()
    {
        selectUser("html-info-prompt");
        comparePrompts({{PromptsModel::Message, "<b>&</b>"},
                        {PromptsModel::Secret, ""}});
    }

    void testInfoAfterLogin()
    {
        selectUser("info-after-login");
        comparePrompts({{PromptsModel::Secret, ""}});
        respond("password", true);
        comparePrompts({{PromptsModel::Message, "Congratulations on logging in!"},
                        {PromptsModel::Button, "Log In"}});
    }

    void testLocked()
    {
        selectUser("locked");
        comparePrompts({{PromptsModel::Secret, ""}});
        respond("nope", false);
        selectUser("locked");
        comparePrompts({{PromptsModel::Error, "Account is locked"},
                        {PromptsModel::Secret, ""}});
    }

private:
    PromptsModel *prompts;
};

QTEST_GUILESS_MAIN(GreeterPromptsModelTest)

#include "promptsmodel.moc"
