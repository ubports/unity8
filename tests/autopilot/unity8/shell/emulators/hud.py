from unity8 import get_grid_size
from unity8.shell.emulators import Unity8EmulatorBase
from autopilot.input import Touch

class Hud(Unity8EmulatorBase):

    """An emulator that understands the Hud."""

    def show(self):
        """Swipes open the Hud."""
        # Todo: assumes the hud is ready and able to be swiped open. Need to
        # check if it's availble before even attempting.
        touch = Touch.create()

        window = self.get_root_instance().select_single('QQuickView')
        hud_show_button = window.select_single("HudButton")

        start_x = int(window.x + (window.width / 2))
        end_x = start_x
        # start_y = window.y + (window.height - 3)
        start_y = window.y + window.height
        end_y = int(hud_show_button.y + (hud_show_button.height/2))

        touch.press(start_x, start_y)
        touch._finger_move(end_x, end_y)
        try:
            hud_show_button.opacity.wait_for(1.0)
            touch.release()
            self.shown.wait_for(True)
        except AssertionError:
            raise
        finally:
            if touch._touch_finger is not None:
                touch.release()

    def dismiss(self):
        """Closes the open Hud."""
        # Ensure that the Hud is actually open
        self.shown.wait_for(True)
        touch = Touch.create()
        x, y = self.get_close_button_coords()
        touch.tap(x, y)

    def get_close_button_coords(self):
        """Returns the coordinates of the Huds close button bar."""
        rect = self.globalRect
        x = int(rect[0] + rect[2] / 2)
        y = rect[1] + get_grid_size()
        return x, y
