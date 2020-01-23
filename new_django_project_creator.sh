#Starts a basic Django project

read -p "Type the projects path (Default: ${HOME}/dev/django_projects): " PROJECTS_PATH
PROJECTS_PATH="${PROJECTS_PATH:=${HOME}/dev/django_projects}"

read -p "Type the project folder name (Default: something): " DIR_NAME
DIR_NAME="${DIR_NAME:=something}"

read -p "Type the project name (Default: my_project): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:=my_project}"

read -p "Type the HTML page source (Default: $HOME/dev/html/landingpage): " HTML_SOURCE
HTML_SOURCE="${HTML_SOURCE:=$HOME/dev/html/landingpage}"

FULL_PATH="$PROJECTS_PATH/$DIR_NAME/$PROJECT_NAME"

mkdir -p "$PROJECTS_PATH/$DIR_NAME"
cd "$PROJECTS_PATH/$DIR_NAME"
python -m venv ".${DIR_NAME}"
source ".${DIR_NAME}/bin/activate"
pip install --upgrade pip
pip install django
django-admin startproject $PROJECT_NAME .
# Enables expand_aliases to allow alias to run inside the script
shopt -s expand_aliases
alias manage="python $VIRTUAL_ENV/../manage.py"
cd $PROJECT_NAME
manage startapp core
sed -i "/^.*django.contrib.staticfiles.*/a \ \ \ \ \'${PROJECT_NAME}.core\'," "$VIRTUAL_ENV/../${PROJECT_NAME}/settings.py"
sed -i "/^from\ django\.urls\ import\ path.*/a from\ ${PROJECT_NAME}\.core\ import\ views" "$VIRTUAL_ENV/../${PROJECT_NAME}/urls.py"
sed -i "/^urlpatterns.*/a \ \ \ \ path('', views.home)," "$VIRTUAL_ENV/../${PROJECT_NAME}/urls.py"
sed -i "s/^.*Create.*/def\ home(request):\n\ \ \ \ return\ render(request,\ \'index.html\')/g" "$VIRTUAL_ENV/../${PROJECT_NAME}/core/views.py"
mkdir core/templates
echo "<html><p>New Project <b>$PROJECT_NAME</b> located at <b>$PROJECTS_PATH/$DIR_NAME</b>.</p></html>" > core/templates/index.html
mkdir core/static
cp -r $HTML_SOURCE/* $FULL_PATH/core/static/
mv core/static/index.html core/templates/
sed -i '1s/^/{% load static %}\n/' core/templates/index.html

manage runserver
