import os
import signal

from supervisor import childutils


while True:
    headers, payload = childutils.listener.wait()
    event = childutils.get_headers(payload)
    if event["processname"] == "oesap":
        try:
            os.killpg(int(event["pid"]), signal.SIGKILL)
        except ProcessLookupError:
            pass
    childutils.listener.ok()
