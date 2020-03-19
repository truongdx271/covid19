import time
import telebot
import sqlite3
from telebot import types

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

bot = telebot.TeleBot(token=TELEGRAM_API_KEY)

bot.enable_save_next_step_handlers(delay=2)

bot.load_next_step_handlers()

def init_conn_db():
  conn = sqlite3.connect('test.db')
  print("Connect database successfully")
  return conn

user_dict = {}

class User:
  def __init__(self, name):
    self.name = name
    self.age = None
    self.sex = None
    self.address = None
    self.salary = None

def find_at(msg):
  for text in msg:
    if '@' in text:
      return text

# @bot.message_handler(commands=['start'])
# def send_welcome(message):
#   bot.reply_to(message, 'Welcome!')

# @bot.message_handler(commands=['help'])
# def send_welcome(message):
#   bot.reply_to(message, 'To use this bot, send it a username')

# @bot.message_handler(func=lambda msg: msg.text is not None and '@' in msg.text)
# def at_answer(message):
#   texts = message.text.split(' ')
#   at_text = find_at(texts)

#   bot.reply_to(message, 'https://instagram.com/{}'.format(at_text[1:]))

######################################################################

# Handle '/start' and '/help'
@bot.message_handler(commands=['help', 'start'])
def send_welcome(message):
  msg = bot.reply_to(message, """\
Hi there, I am Example bot.
What's your name?
""")
  bot.register_next_step_handler(msg, process_name_step)

def process_name_step(message):
  try:
    chat_id = message.chat.id
    name = message.text
    user = User(uid,name)
    user_dict[chat_id] = user
    msg = bot.reply_to(message, 'How old are you?')
    bot.register_next_step_handler(msg, process_age_step)
  except Exception as e:
    bot.reply_to(message, 'oooops')

def process_age_step(message):
  try:
    chat_id = message.chat.id
    age = message.text
    if not age.isdigit():
      msg = bot.reply_to(message, 'Age should be a number. How old are you?')
      bot.register_next_step_handler(msg, process_age_step)
      return
    user = user_dict[chat_id]
    user.age = age
    markup = types.ReplyKeyboardMarkup(one_time_keyboard=True)
    markup.add('Male', 'Female')
    msg = bot.reply_to(message, 'What is your gender', reply_markup=markup)
    bot.register_next_step_handler(msg, process_sex_step)
  except Exception as e:
    bot.reply_to(message, 'oooops')

def process_sex_step(message):
  try:
    chat_id = message.chat.id
    sex = message.text
    user = user_dict[chat_id]
    if (sex == u'Male') or (sex == u'Female'):
      user.sex = sex
    else:
      raise Exception()
    # bot.send_message(chat_id, 'Nice to meet you ' + user.name + '\n Age:' + str(user.age) + '\n Sex:' + user.sex + '\n Tell me your address!')
    msg = bot.reply_to(message, 'What is your address')
    bot.register_next_step_handler(msg, process_address_step)
  except Exception as e:
    bot.reply_to(message, 'oooops')

def process_address_step(message):
  try:
    chat_id = message.chat.id
    address = message.text
    user = user_dict[chat_id]
    user.address = address
    msg = bot.reply_to(message, 'What is your salary')
    bot.register_next_step_handler(msg, process_salary_step)
  except Exception as e:
    bot.reply_to(message, 'oooops')

def process_salary_step(message):
  try:
    chat_id = message.chat.id
    salary = message.text
    if not salary.isdigit():
      msg = bot.reply_to(message, 'Salary should be a number!')
      bot.register_next_step_handler(msg, process_salary_step)
      return
    user = user_dict[chat_id]
    user.salary = salary
    bot.send_message(chat_id, 'Nice to meet you ' + user.name + '\n Age: ' + user.age + '\n Sex: ' + user.sex + '\n Address: ' + user.address + '\n Salary: ' + user.salary)
    last = insert_user_to_db(user)
    print 'last userid: ' + last
  except Exception as e:
    bot.reply_to(message, 'oooops')

def insert_user_to_db(user):
  conn = init_conn_db()
  sql = '''INSERT INTO COMPANY (NAME,AGE,SEX,ADDRESS,SALARY) VALUES (?,?,?,?,?)'''
  cur = conn.cursor()
  cur.execute(sql,user)
  return cur.lastrowid

bot.polling()
bot.polling(none_stop=True)
bot.polling(interval=3)

while True:
  pass