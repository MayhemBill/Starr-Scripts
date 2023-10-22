import argparse
import json
import requests
import os
from dotenv import load_dotenv
envpath = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', '.env'))
load_dotenv(envpath)
NOTIFIARR_APIKEY = os.getenv('NOTIFIARR_APIKEY')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Example: python notifiarr.py -e "System Backup" -c 735481457153277994 -m "FFA500" -t "Backup Failed" -f "[{\\"Reason\\": \\"Permissions error\\"}, {\\"Severity\\": \\"Critical\\"}]" -g "[{\\"Reason\\": \\"Permissions error\\"}, {\\"Severity\\": \\"Critical\\"}]" -a "https://notifiarr.com/images/logo/notifiarr.png" -z "Passthrough Integration"')
    parser.add_argument('-e', '--event', dest='event', help='notification type (rclone for example)', type=str, required=True, metavar='')
    parser.add_argument('-c', '--channel', dest='channel', help='valid discord channel id', type=int, required=True, metavar='')
    parser.add_argument('-t', '--title', dest='title', help='text title of message (rclone started for example)', type=str, required=True, metavar='')
    parser.add_argument('-b', '--body', dest='body', help='if fields is not used, text body for message', type=str, metavar='')
    parser.add_argument('-f', '--fields', dest='fields_not_inline', help='if body is not used, valid JSON list of fields [{title,text},{title,text}] max 25 list items (not inline)', type=str, metavar='')
    parser.add_argument('-g', '--inline', dest='fields_inline', help='if body is not used, valid JSON list of fields [{title,text},{title,text}] max 25 list items (inline)', type=str, metavar='')
    parser.add_argument('-z', '--footer', dest='footer', help='text footer of message', default='', type=str, metavar='')
    parser.add_argument('-a', '--avatar', dest='avatar', help='valid url to image', default='', type=str, metavar='')
    parser.add_argument('-i', '--thumbnail', dest='thumbnail', help='valid url to image', default='', type=str, metavar='')
    parser.add_argument('-m', '--color', dest='color', help='6 digit html code for the color', default='', type=str, metavar='')
    parser.add_argument('-u', '--ping-user', dest='ping_user', help='valid discord user id', default=0, type=int, metavar='')
    parser.add_argument('-r', '--ping-role', dest='ping_role', help='valid discord role id', default=0, type=int, metavar='')
    args = parser.parse_args()

    if not NOTIFIARR_APIKEY:
        raise Exception('ERROR: Edit the script and add your Notifiarr apikey')

    if not args.body and not args.fields_not_inline and not args.fields_inline:
        raise Exception('ERROR: Either -b/--body or -f/--fields or -g/--inline is required')

    inlineFields = []
    singleFields = []

    if args.fields_inline:
        inlineFields = [{'title': t, 'text': x, 'inline': True} for f in json.loads(args.fields_inline) for t, x in f.items()] if args.fields_inline else []

    if args.fields_not_inline:
        singleFields = [{'title': t, 'text': x, 'inline': False} for f in json.loads(args.fields_not_inline) for t, x in f.items()] if args.fields_not_inline else []

    fields = inlineFields + singleFields

    # BUILD THE TEMPLATE
    notifiarr_payload = {
        'notification': {
            'update': False,
            'name': args.event,
            'event': 0
        },
        'discord': {
            'color': args.color,
            'ping': {
                'pingUser': args.ping_user,
                'pingRole': args.ping_role
            },
            'images': {
                'thumbnail': args.thumbnail,
                'image': ''
            },
            'text': {
                'title': args.title,
                'icon': args.avatar,
                'content': '',
                'description': args.body,
                'fields': fields,
                'footer': args.footer
            },
            'ids': {
                'channel': args.channel
            }
        }
    }

    # PUSH THE WEBHOOK
    r = requests.post(f'https://notifiarr.com/api/v1/notification/passthrough/{NOTIFIARR_APIKEY}', data=json.dumps(notifiarr_payload), headers={'Content-type': 'application/json', 'Accept': 'text/plain'})
    #print(r.text)
