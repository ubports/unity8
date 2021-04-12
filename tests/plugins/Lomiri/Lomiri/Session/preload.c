/*
 * Copyright © 2017 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
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

#include <glib.h>
#include <grp.h>
#include <stdlib.h>

const gchar *g_get_user_name(void)
{
    // The normal glib version parses pwent entries
    return g_getenv("TEST_USER");
}

struct group *getgrnam(const char *group_name)
{
    static struct group rv = {NULL, NULL, 0, NULL};

    g_free(rv.gr_name);
    g_strfreev(rv.gr_mem);

    rv.gr_name = g_strdup(group_name);
    rv.gr_passwd = NULL;
    rv.gr_gid = 9999;
    rv.gr_mem = NULL;
    if (g_strcmp0(group_name, "nopasswdlogin") == 0) {
        rv.gr_mem = g_strsplit(g_getenv("TEST_NOPASSWD_USERS"), ",", 0);
    }
    return &rv;
}
