/*
 * Copyright 2014 Canonical Ltd.
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
 */

#include "relativetimeformatter.h"

#include <QDateTime>

#include <glib.h>
#include <locale.h>
#include <langinfo.h>
#include <libintl.h>

RelativeTimeFormatter::RelativeTimeFormatter(QObject *parent)
    : GDateTimeFormatter(parent)
{
}

/* Check the system locale setting to see if the format is 24-hour
   time or 12-hour time */
gboolean
is_locale_12h(void)
{
    int i;
    static const char *formats_24h[] = {"%H", "%R", "%T", "%OH", "%k", NULL};
    const char* t_fmt = nl_langinfo(T_FMT);

    for (i=0; formats_24h[i]!=NULL; i++)
        if (strstr(t_fmt, formats_24h[i]) != NULL)
            return FALSE;

    return TRUE;
}


typedef enum
{
    DATE_PROXIMITY_TODAY,
    DATE_PROXIMITY_YESTERDAY,
    DATE_PROXIMITY_WEEK,
    DATE_PROXIMITY_FAR
}
date_proximity_t;

static date_proximity_t
getDateProximity(GDateTime* now, GDateTime* time)
{
    date_proximity_t prox = DATE_PROXIMITY_FAR;
    gint now_year, now_month, now_day;
    gint time_year, time_month, time_day;

    // does it happen today?
    g_date_time_get_ymd(now, &now_year, &now_month, &now_day);
    g_date_time_get_ymd(time, &time_year, &time_month, &time_day);
    if ((now_year == time_year) && (now_month == time_month) && (now_day == time_day)) {
        return DATE_PROXIMITY_TODAY;
    }

    // does it happen tomorrow?
    GDateTime* tomorrow = g_date_time_add_days(now, -1);
    gint tom_year, tom_month, tom_day;
    g_date_time_get_ymd(tomorrow, &tom_year, &tom_month, &tom_day);
    if ((tom_year == time_year) && (tom_month == time_month) && (tom_day == time_day))
        return DATE_PROXIMITY_YESTERDAY;
    g_date_time_unref(tomorrow);

    // does it happen this week?
    if (prox == DATE_PROXIMITY_FAR) {
        GDateTime* week = g_date_time_add_days(now, -6);
        GDateTime* week_bound = g_date_time_new_local(g_date_time_get_year(week),
                                                g_date_time_get_month(week),
                                                g_date_time_get_day_of_month(week),
                                                23, 59, 59.9);

        if (g_date_time_compare(time, week_bound) >= 0)
            prox = DATE_PROXIMITY_WEEK;

        g_date_time_unref(week_bound);
        g_date_time_unref(week);
    }

    return DATE_PROXIMITY_FAR;
}

/**
 * _ a time today should be shown as just the time (e.g. “3:55 PM”)
 * _ a full-day event today should be shown as “Today”
 * _ a time any other day this week should be shown as the short version of the
 *   day and time (e.g. “Wed 3:55 PM”)
 * _ a full-day event tomorrow should be shown as “Tomorrow”
 * _ a full-day event another day this week should be shown as the
 *   weekday (e.g. “Friday”)
 * _ a time after this week should be shown as the short version of the day,
 *   date, and time (e.g. “Wed 21 Apr 3:55 PM”)
 * _ a full-day event after this week should be shown as the short version of
 *   the day and date (e.g. “Wed 21 Apr”).
 * _ in addition, when presenting the times of upcoming events, the time should
 *   be followed by the timezone if it is different from the one the computer
 *   is currently set to. For example, “Wed 3:55 PM UTC−5”.
 */
char* generate_full_format_string_at_time (GDateTime* now,
                                           GDateTime* then)
{
    GString* ret = g_string_new (NULL);

    if (then != NULL) {
        const date_proximity_t prox = getDateProximity(now, then);

        if (is_locale_12h()) {
            switch (prox)  {
                case DATE_PROXIMITY_TODAY:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 12-hour clock, times that happened today.
                       en_US example: "%l:%M %p" --> "1:00 PM" */
                    g_string_assign (ret, gettext("%l:%M %p"));
                    break;

                case DATE_PROXIMITY_YESTERDAY:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 12-hour clock, times that happen yesterday.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "Yesterday\u2003%l:%M %p" --> "Tomorrow  1:00 PM" */
                    g_string_assign (ret, gettext("Yesterday\u2003%l:%M %p"));
                    break;

                case DATE_PROXIMITY_WEEK:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 12-hour clock, times that happened in the last week.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "%a\u2003%l:%M %p" --> "Fri  1:00 PM" */
                    g_string_assign (ret, gettext("%a\u2003%l:%M %p"));
                    break;

                case DATE_PROXIMITY_FAR:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 12-hour clock, times that happened before a week from now.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "%a %d %b\u2003%l:%M %p" --> "Fri Oct 31  1:00 PM"
                       en_GB example: "%a %b %d\u2003%l:%M %p" --> "Fri 31 Oct  1:00 PM" */
                    g_string_assign (ret, gettext("%a %d %b\u2003%l:%M %p"));
                    break;
            }
        } else {
            switch (prox) {
                case DATE_PROXIMITY_TODAY:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 24-hour clock, times that happened today.
                       en_US example: "%H:%M" --> "13:00" */
                    g_string_assign (ret, gettext("%H:%M"));
                    break;

                case DATE_PROXIMITY_YESTERDAY:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 24-hour clock, times that happen yesterday.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "Yesterday\u2003%l:%M %p" --> "Tomorrow  13:00" */
                    g_string_assign (ret, gettext("Yesterday\u2003%H:%M"));
                    break;

                case DATE_PROXIMITY_WEEK:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 24-hour clock, times that happened in the last week.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "%a\u2003%H:%M" --> "Fri  13:00" */
                    g_string_assign (ret, gettext("%a\u2003%H:%M"));
                    break;

                case DATE_PROXIMITY_FAR:
                    /* Translators, please edit/rearrange these strftime(3) tokens to suit your locale!
                       This format string is used for showing, on a 24-hour clock, times that happened before a week from now.
                       (\u2003 is a unicode em space which is slightly wider than a normal space.)
                       en_US example: "%a %d %b\u2003%H:%M" --> "Fri Oct 31  13:00"
                       en_GB example: "%a %b %d\u2003%H:%M" --> "Fri 31 Oct  13:00" */
                    g_string_assign (ret, gettext("%a %d %b\u2003%H:%M"));
                    break;
            }
        }
    }

    return g_string_free (ret, FALSE);
}

QString RelativeTimeFormatter::format() const
{
    GDateTime* now = g_date_time_new_from_unix_utc(QDateTime::currentMSecsSinceEpoch() / 1000);
    if (!now) { return QString(); }

    GDateTime* then = g_date_time_new_from_unix_local(time());
    if (!then) { return QString(); }

    char* time_format = generate_full_format_string_at_time(now, then);

    QString str(QString::fromUtf8(time_format));
    g_free(time_format);

    g_date_time_unref(now);
    g_date_time_unref(then);

    return str;
}
