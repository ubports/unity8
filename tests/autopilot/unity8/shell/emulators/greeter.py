from unity8.shell.emulators import Unity8EmulatorBase
from autopilot.input import Touch


class Greeter(Unity8EmulatorBase):

    """An emulator that understands the greeter screen."""

    def unlock(self):
        """Swipe the greeter screen away."""
        self.created.wait_for(True)
        touch = Touch.create()

        # TODO: Is this ever called? Find out, and maybe remove this branch:
        if self.multiUser:
            # this is borked!
            password_field = self.select_greeter_user("No Password")
            password_field.opacity.wait_for(1)
            touch.tap_object(password_field)

        else:
            rect = self.globalRect
            start_x = rect[0] + rect[2] - 3
            start_y = int(rect[1] + rect[3] / 2)
            stop_x = int(rect[0] + rect[2] * 0.2)
            stop_y = start_y
            touch.drag(start_x, start_y, stop_x, stop_y)

        self.created.wait_for(False)
