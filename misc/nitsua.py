import json
import subprocess

NOTIFIARR_PY = '/mnt/development/scripts/misc/notifiarr.py'

webhook = "python3 " + NOTIFIARR_PY + " -e \"Errors\" -c 1164585523348783104 -m \"FFA500\" -t \"Error\" -b \"URLs found with errors\" -a \"https://notifiarr.com/images/logo/notifiarr.png\" -z \"Passthrough Integration\""
subprocess.call(webhook)
