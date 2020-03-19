import requests
import os
import sys
import time

COUNTRY = ''
TELEGRAM_API_KEY = ''
TELEGRAM_CHAT_ID = ''
urldata = sys.argv[1]

with open ('api.key', 'r') as reader:
  for line in reader.readlines():
    if line is not None:
      if 'KEY' in line:
        TELEGRAM_API_KEY = line.split('=')[1].rstrip('\r\n')
      if 'ID' in line:
        TELEGRAM_CHAT_ID = line.split('=')[1].rstrip('\r\n')
      if 'COUNTRY' in line:
        COUNTRY = line.split('=')[1].rstrip('\r\n')
    else:
      continue

url = 'https://api.telegram.org/bot' + TELEGRAM_API_KEY +'/sendMessage?chat_id=' + TELEGRAM_CHAT_ID + '&parse_mode=Markdown&text=' + urldata
r = requests.post(url)