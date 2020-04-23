# This script create a Django project ready to deploy

PROJECTS_ROOT=${HOME}/dev/django_projects
PROJECT=mysite

mkdir -p ${PROJECTS_ROOT}/${PROJECT}
cd ${PROJECTS_ROOT}/${PROJECT}

python -m venv '.'$PROJECT

source '.'$PROJECT'/bin/activate'

pip install pip --upgrade

pip install django dj-database-url dj-static python-decouple

django-admin startproject $PROJECT .
alias manage='python $VIRTUAL_ENV/../manage.py'

echo 'DEBUG=False' > .env
{ echo -n SECRET_KEY= ; grep -oP "SECRET_KEY = '(.*)'" $PROJECT/settings.py | cut -d\' -f2 ; } | tr "" "" >> .env
echo 'ALLOWED_HOSTS=127.0.0.1, .localhost, .herokuap.com, .danilosantos.local' >> .env

cp ../settings.py $PROJECT
sed -i "/WSGI_APPLICATION = /c\WSGI_APPLICATION = '${PROJECT}.wsgi.application'" ${PROJECT}/settings.py
sed -i "/ROOT_URLCONF = /c\ROOT_URLCONF = '${PROJECT}.urls'" ${PROJECT}/settings.py
sed -i "/ALLOWED_HOSTS = /c\ALLOWED_HOSTS = config('ALLOWED_HOSTS', default=[], cast=Csv())" ${PROJECT}/settings.py

cp ../wsgi.py $PROJECT

# Create app
cd $PROJECT
manage startapp core
cd ..

# Insert app to INSTALED_APPS
sed -i "/^.*django.contrib.staticfiles.*/a \ \ \ \ \'${PROJECT}.core\'," "$VIRTUAL_ENV/../${PROJECT}/settings.py"

# Insert route to urls.py
sed -i "/^from\ django\.urls\ import\ path.*/a from\ ${PROJECT}\.core\ import\ views" "$VIRTUAL_ENV/../${PROJECT}/urls.py"
sed -i "/^urlpatterns.*/a \ \ \ \ path('', views.home)," "$VIRTUAL_ENV/../${PROJECT}/urls.py"

# Insert a view
sed -i "s/^.*Create.*/def\ home(request):\n\ \ \ \ return\ render(request,\ \'index.html\')/g" "$VIRTUAL_ENV/../${PROJECT}/core/views.py"

# Create template
mkdir $VIRTUAL_ENV/../${PROJECT}/core/templates
echo "<html><p>Index of <b>$PROJECT</b></p></html>" > $VIRTUAL_ENV/../${PROJECT}/core/templates/index.html

# Create static files folder
mkdir $VIRTUAL_ENV/../${PROJECT}/core/static
#mv $VIRTUAL_ENV/../${PROJECT}/core/static/index.html $VIRTUAL_ENV/../${PROJECT}/core/templates/
#sed -i '1s/^/{% load static %}\n/' $VIRTUAL_ENV/../${PROJECT}/core/templates/index.html


pip freeze > requirements.txt
echo 'gunicorn' >> requirements.txt
echo 'psycopg2' >> requirements.txt

# Criar Procfile
echo 'web: gunicorn '$PROJECT'.wsgi --log-file -' > Procfile

# Prepare to push
git init
echo '.'$PROJECT > .gitignore
echo '*.sqlite3' >> .gitignore
echo '.env' >> .gitignore
echo '*.pyc' >> .gitignore
echo '__cache__' >> .gitignore
git add .
git commit -m 'First commit'


manage migrate
manage collectstatic
manage runserver 0.0.0.0:8000

