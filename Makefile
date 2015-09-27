.PHONY: run test initdb dropdb
run: initdb
	# DEBUG=1 python index.py
	python index.py
run-in-docker: initdb
	gunicorn -b 0.0.0.0:5000 -c config.py index:app
run-in-heroku: initdb
	sed -i "s/xxxxxxxxx/${NEW_RELIC_API_KEY}/" config/newrelic.ini
	mkdir -p logs/nginx
	touch /tmp/app-initialized
	bin/start-nginx gunicorn -c config.py index:app
test:
	python -m unittest discover ./test
dropdb:
	python -c 'from models import db; db.drop_all()'
initdb:
	-echo create database hndigest ENCODING "'UTF8'" TEMPLATE template0 | sudo -u postgres psql
	-echo create database hndigest ENCODING "'UTF8'" TEMPLATE template0 | sudo su - postgres -c psql
	python -c 'from models import db; db.create_all()'
