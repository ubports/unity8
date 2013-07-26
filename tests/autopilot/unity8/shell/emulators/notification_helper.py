from multiprocessing import Process, JoinableQueue, Queue
from gi.repository import GLib, Notify
from Queue import Empty


class Notifications(object):

    """A simple context manager that allows tests to fire off notifications that
     include callbacks and hints.

    """
    LOW = Notify.Urgency.LOW
    NORMAL = Notify.Urgency.NORMAL
    CRITICAL = Notify.Urgency.CRITICAL

    def __enter__(self):
        # A queue of tasks to the notification process. Each one represents a
        # notification to send, or possibly a command.
        self._task_queue = JoinableQueue(maxsize=128)

        # A queue of results from the notification process.
        self._result_queue = Queue(maxsize=128)
        self._process = Process(
            target=_run,
            args=(
                self._task_queue,
                self._result_queue
            )
        )
        self._process.start()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self._quit()

    def _quit(self):
        self._task_queue.put(("Quit",))
        self._process.join()

    def _wait_for_result(self, timeout):
        return self._result_queue.get(timeout=timeout)

    def assert_callback_called(self, action_id, timeout):
        """Assert that the callback specified by 'action_id' was called within
        a certain timeout.

        """
        try:
            t, result = self._wait_for_result(timeout)
            if t != "callback":
                raise AssertionError(
                    "While waiting for callback '%s', the notification was "
                    "closed." % action_id
                )
            if result != action_id:
                raise AssertionError(
                    "While waiting for callback '%s', the notification %s was "
                    "called instead." % (action_id, result)
                )
        except Empty:
            raise AssertionError(
                "Callback '%s' was not called within timeout of %d seconds"
                % (action_id, timeout)
            )

    def assert_notification_closed(self, timeout):
        """Assert that the current notification was closed within the specified
        timeout.

        """
        try:
            t, result = self._wait_for_result(timeout)
            if t != "close":
                raise AssertionError(
                    "While waiting for callback to be closed, it was activated"
                    " instead"
                )
        except Empty:
            raise AssertionError(
                "Callback was not closed within timeout of %d seconds"
                % timeout
            )

    def interactive_notification(
        self,
        summary="",
        body="",
        icon=None,
        urgency="NORMAL",
        action_id="action_id",
        action_label="action_label",
        hint_strings=[],
    ):
        """Create an Interactive notification command.

        :param summary: Summary text for the notification
        :param body: Body text to display in the notification
        :param icon: Path string to the icon to use
        :param urgency: Urgency for the noticiation, either: Notifications.LOW,
            Notifications.NORMAL, Notifications.CRITICAL
        :param action_id: String containing id to store for the callback
        :param action_label: String to display on the notification
        :param hint_strings: List of tuples containing the 'name' and value for
            setting the hint strings for the notification

        """
        self._task_queue.put((
            "Interactive",
            summary,
            body,
            icon,
            urgency,
            action_id,
            action_label,
            hint_strings,
        ))
        self._task_queue.join()


def _run(task_queue, result_queue):
    notifications = []

    def _check_queue_for_new_task(*args):
        try:
            command = task_queue.get(False)
        except Empty:
            pass
        else:
            try:
                if command[0] == "Quit":
                    loop.quit()
                elif command[0] == "Interactive":
                    summary = command[1]
                    body = command[2]
                    icon = command[3]
                    urgency = command[4]
                    action_id = command[5]
                    action_label = command[6]
                    hint_strings = command[7]

                    notification = Notify.Notification.new(summary, body, icon)
                    for hint in hint_strings:
                        name, value = hint
                        notification.set_hint_string(name, value)
                    # notification.set_hint_string ("x-canonical-switch-to-application", "true")
                    notification.add_action(
                        action_id,
                        action_label,
                        _action_callback,
                        None,
                        None
                    )
                    notification.connect('closed', _quit_callback)
                    notification.show()
                    notifications.append(notification)
            finally:
                task_queue.task_done()

        return True

    def _action_callback(notification, action_id, data):
        notifications.remove(notification)
        result_queue.put(("callback", action_id))

    def _quit_callback(*args):
        result_queue.put(("quit",))

    # we'll check for new tasks in the input queue every 200 mS
    GLib.timeout_add(200, _check_queue_for_new_task, None)

    # create the GLib mainloop and start it running:
    Notify.init("Autopilot notification thingy")
    loop = GLib.MainLoop()
    loop.run()
    Notify.uninit()
