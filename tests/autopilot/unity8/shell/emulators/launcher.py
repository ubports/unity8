from unity8.shell.emulators import Unity8EmulatorBase
from autopilot.input import Touch

class Launcher(Unity8EmulatorBase):

    """An emulator that understands the Launcher."""

    def show(self):
        """Swipes open the launcher."""
        touch = Touch.create()

        view = self.get_root_instance().select_single('QQuickView')
        start_x = view.x + 1
        start_y = view.y + view.height / 2
        stop_x = start_x + self.panelWidth + 1
        stop_y = start_y
        touch.drag(start_x, start_y, stop_x, stop_y)
        self.shown.wait_for(True)
