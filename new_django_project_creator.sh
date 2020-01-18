#!/bin/bash
#Starts a basic Django project

PROJECTS_PATH="${HOME}/Desenvolvimento/django_projects" # Set a existing folder
DIR_NAME="something"
PROJECT_NAME="my_project"

cd $PROJECTS_PATH
mkdir $DIR_NAME
cd $DIR_NAME
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
echo "<html><h1>New Django Project</h1></html>" > core/templates/index.html
manage runserver
