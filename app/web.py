from psycopg2 import connect
from flask import Flask
from configparser import ConfigParser


app = Flask(__name__)


def get_db_config(db_option):
	config = ConfigParser()
	config.read('/srv/app/conf/web.conf')
	try:
		result = config.get("database", db_option)
	except configparser.NoSectionError:
		print ('Cannot get {}. There is no such section or config file is unavailable/does not exist').format(db_option)
		exit ()
	return result


## DEBUG: print connection conf
#print("\n=CONNECTION PARAMS:\n db_host: {0}\n db_port: {1}\n db_name: {2}\n db_user: {3}\n db_password: {4} \n".format(get_db_config('db_host'), get_db_config('db_port'), get_db_config('db_name'), get_db_config('db_user'), get_db_config('db_password')))


def get_db_user():
	#conn = connect("host=10.0.10.10 port=5432 dbname=acme_db user=acme_db_admin password=pass1234")
	#conn = connect("host={0} dbname={1} user={2} password={3}".format(get_db_config('db_host'), get_db_config('db_name'), get_db_config('db_user'), get_db_config('db_password')))
	conn = connect("host={0} port={1} dbname={2} user={3} password={4}".format(get_db_config('db_host'), get_db_config('db_port'), get_db_config('db_name'), get_db_config('db_user'), get_db_config('db_password')))
	conn.autocommit = True
	cur = conn.cursor()
	cur.execute('SELECT current_user;;')
	return cur.fetchone()

def get_db_time():
	#conn = connect("host=10.0.10.10 port=5432 dbname=acme_db user=acme_db_admin password=pass1234")
	conn = connect("host={0} port={1} dbname={2} user={3} password={4}".format(get_db_config('db_host'), get_db_config('db_port'), get_db_config('db_name'), get_db_config('db_user'), get_db_config('db_password')))
	conn.autocommit = True
	cur = conn.cursor()
	#cur.execute('SELECT now() AT TIME ZONE \'UTC\';')  ## (datetime.datetime(2023, 3, 7, 6, 2, 47, 463365),)
	#cur.execute('SELECT now() AT TIME ZONE \'UTC\';')  ## 2023-03-07 06:05:40.692629
	cur.execute('SELECT now() AT TIME ZONE \'ALMT\';')  ## 2023-03-07 12:15:42.796842 (UTC+06:00, Almaty,Novosibirsk,Omsk)
	return cur.fetchone()


## OLD
#text = """<h1 style='color:blue'>Hello there!</h1>Everything is OK! DB Query was completed by '{}' user""".format(get_db_user()[0])

## NEW
html_code = """
<h1 style='color:blue'>Hello there!</h1>
Everything is OK! DB Query was completed by '{0}' user.
<hr>
PostgreSQL Application start time: {1}
""".format(get_db_user()[0], get_db_time()[0])



@app.route("/")


def hello():
	#return text
	return html_code

if __name__ == "__main__":
	app.run(host='0.0.0.0')
