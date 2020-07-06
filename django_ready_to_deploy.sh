# This script create a Django project ready to deploy

# Define variables
PROJECTS_ROOT="${HOME}/dev/django_projects"
PROJECT=sampleproject
URL=$PROJECT'.dokku.local'

# Open project folder
mkdir -p ${PROJECTS_ROOT}/${PROJECT}
cd ${PROJECTS_ROOT}/${PROJECT}

# Environment
python -m venv '.'$PROJECT
source '.'$PROJECT'/bin/activate'
pip install --upgrade pip
pip install django dj-database-url dj-static python-decouple

# Create project
django-admin startproject $PROJECT .
alias manage='python $VIRTUAL_ENV/../manage.py'

# Define environments variables
echo 'DEBUG=True' > .env
{ echo -n SECRET_KEY= ; grep -oP "SECRET_KEY = '(.*)'" $PROJECT/settings.py | cut -d\' -f2 ; } | tr "" "" >> .env
echo 'ALLOWED_HOSTS=127.0.0.1, .localhost, .herokuap.com, .'$URL >> .env
mkdir contrib
echo 'DEBUG=True' > contrib/env-sample
echo 'SECRET_KEY=CHANGE_THIS_SECRET_KEY' >> contrib/env-sample
echo 'ALLOWED_HOSTS=127.0.0.1, .localhost, .herokuap.com, .'$URL >> contrib/env-sample 

# Secret Key generator
echo -e """\
#!/usr/bin/env python

from django.utils.crypto import get_random_string

chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
print(get_random_string(50, chars))
"""> contrib/secret_gen.py

# Edit settings.py
sed -i "s/^import os$/import os\nfrom decouple import config, Csv\nfrom dj_database_url import parse as dburl/" ${PROJECT}/settings.py  # Insert imports
sed -i "/^SECRET_KEY = /c\SECRET_KEY = config('SECRET_KEY')" ${PROJECT}/settings.py # Replace SECRET_KEY
sed -i "/^DEBUG = /c\DEBUG = config('DEBUG', default=False, cast=bool)" ${PROJECT}/settings.py # Replace DEBUG
sed -i "/^ALLOWED_HOSTS = /c\ALLOWED_HOSTS = config('ALLOWED_HOSTS', default=[], cast=Csv())" ${PROJECT}/settings.py # Replace ALLOWED_HOSTS
sed -i -e "/^DATABASES =/{n;N;N;N;N;d}" ${PROJECT}/settings.py # Delete 5 lines below DATABASES
sed -i "/^DATABASES = /c\default_dburl = 'sqlite:///' + os.path.join(BASE_DIR, 'db.sqlite3')\nDATABASES = {\n    'default': config('DATABASE_URL', default=default_dburl, cast=dburl),\n}" ${PROJECT}/settings.py  # Replace DATABASES
sed -i "/^ROOT_URLCONF = /c\ROOT_URLCONF = '${PROJECT}.urls'" ${PROJECT}/settings.py
sed -i "/^WSGI_APPLICATION = /c\WSGI_APPLICATION = '${PROJECT}.wsgi.application'" ${PROJECT}/settings.py
sed -i "/^LANGUAGE_CODE = /c\LANGUAGE_CODE = 'pt-BR'" ${PROJECT}/settings.py
sed -i "/^TIME_ZONE = /c\TIME_ZONE = 'America/Bahia'" ${PROJECT}/settings.py
sed -i "/^STATIC_URL = /c\STATIC_URL = '/static/'\nSTATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')" ${PROJECT}/settings.py # Insert STATIC_ROOT

# Edit wsgi.py
sed -i 's/^import os$/import os\nfrom dj_static import Cling/' ${PROJECT}/wsgi.py
sed -i "/^application = /c\application = Cling(get_wsgi_application())" ${PROJECT}/wsgi.py

# Create app
APP_NAME=core
cd $VIRTUAL_ENV/../${PROJECT}
manage startapp ${APP_NAME}
cd ..

# Insert app to INSTALED_APPS
sed -i "/^.*django.contrib.staticfiles.*/a \ \ \ \ \'${PROJECT}.${APP_NAME}\'," "$VIRTUAL_ENV/../${PROJECT}/settings.py"

# Insert route to urls.py
sed -i "/^from\ django\.urls\ import\ path.*/a from\ ${PROJECT}\.${APP_NAME}\ import\ views" "$VIRTUAL_ENV/../${PROJECT}/urls.py"
sed -i "/^urlpatterns.*/a \ \ \ \ path('', views.home)," "$VIRTUAL_ENV/../${PROJECT}/urls.py"

# Insert a view
sed -i "s/^.*Create.*/def\ home(request):\n\ \ \ \ return\ render(request,\ \'index.html\')/g" "$VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/views.py"

# Create template
mkdir -p $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/templates
echo "<html><p>Index of <b>$PROJECT</b></p></html>" > $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/templates/index.html

# Create static files folder
mkdir $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/static
#mv $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/static/index.html $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/templates/
#sed -i '1s/^/{% load static %}\n/' $VIRTUAL_ENV/../${PROJECT}/${APP_NAME}/templates/index.html

# Create Procfile
echo -e  '''\
web: gunicorn '$PROJECT'.wsgi --log-file -
release: python manage.py makemigrations --noinput & python manage.py migrate --noinput
''' >> Procfile

# Define python version on deploy
echo 'python-3.8.2' > runtime.txt

# Create requirements-dev file
pip freeze > requirements-dev.txt

# Create requirements file (to deploy)
echo '-r requirements-dev.txt' >> requirements.txt
echo 'gunicorn' >> requirements.txt
echo 'psycopg2' >> requirements.txt
