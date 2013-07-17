from unity8.shell.emulators import Unity8EmulatorBase


class Dash(Unity8EmulatorBase):

    """An emulator that understands the Dash."""

    def get_home_applications_grid(self):
        return self.select_single(
            "ApplicationsFilterGrid",
            objectName="dashHomeApplicationsGrid"
        )

    def get_application_icon(self, text):
        """Returns a 'Tile' icon that has the text 'text' from the application
        grid.

        Will return None if the icon isn't found.

        :param text: String containing the text of the icon to search for.
        """
        app_grid = self.get_home_applications_grid()
        resp_grid = app_grid.select_single('ResponsiveGridView')
        return resp_grid.select_single('Tile', text=text)
