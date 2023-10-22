import os
import subprocess
import os.path as path
from dotenv import load_dotenv
ENVPATH = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', '.env'))
load_dotenv(ENVPATH)
print (ENVPATH)
NOTIFIARRPY = os.path.abspath(os.path.join(os.path.dirname( __file__ ), 'notifiarr.py'))
PYTHONPATH = os.getenv('PYTHON_PATH')
webhook = PYTHONPATH + " " + NOTIFIARRPY + " -e \"Plex DB Backup\" -c 1164585523348783104 -m \"FFA500\" -t \"Backup Success \" -b \"DB Successfully backed up\" -g \"" "\" -a \"https://notifiarr.com/images/logo/notifiarr.png\" -z \"Passthrough Integration\""
subprocess.call(webhook)
