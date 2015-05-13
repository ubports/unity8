
from contextlib import contextmanager


@contextmanager
def override_proxy_timeout(proxy, timeout_seconds):
    original_timeout = proxy._poll_time
    try:
        proxy._poll_time = timeout_seconds
        yield proxy
    finally:
        proxy._poll_time = original_timeout
