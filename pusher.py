import requests
import os
import sys

TELEGRAM_API_KEY = sys.argv[1] 
TELEGRAM_CHAT_ID = sys.argv[2]
urldata = sys.argv[3]

url = 'https://api.telegram.org/bot' + TELEGRAM_API_KEY +'/sendMessage?chat_id=' + TELEGRAM_CHAT_ID + '&parse_mode=Markdown&text=' + urldata

print(url)

r = requests.post(url)
