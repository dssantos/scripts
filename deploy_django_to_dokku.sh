# This scrip performs the deploy of Django application on Dokku

# Define variables
PROJECT=app1
PROJECT_DB=$PROJECT'_db'
DOMAIN=dokku.local

# Install psql client
sudo apt install postgresql-client

# Access project folder
cd $HOME'/dev/django_projects/'$PROJECT
source '.'$PROJECT'/bin/activate'

# Create app
dokku apps:create $PROJECT

# Configure dokku environment vars
dokku config:set $PROJECT DEBUG='False'
NEW_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
dokku config:set $PROJECT SECRET_KEY=$NEW_KEY
dokku config:set $PROJECT ALLOWED_HOSTS='127.0.0.1, .localhost, .herokuap.com, .'${DOMAIN}

# Show variables
dokku config $PROJECT

# Install postgres plugin
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git

# Create a postgres database service
dokku postgres:create $PROJECT_DB

# Link app to database
dokku postgres:link $PROJECT_DB $PROJECT

# Create database's app
DB_SERVER=$(dokku postgres:info $PROJECT_DB | grep "Internal ip:" | grep -oE '([0-9]{1,3}\.?){4}')
PASS=$(dokku postgres:info $PROJECT_DB | grep "Dsn:"| cut -d\: -f4 | cut -d@ -f1)   # Captura a linha com 'Dsn', fatia pelo ':', depois fatia pelo '@'
PGPASSWORD=$PASS psql -h $DB_SERVER -U postgres -c 'CREATE DATABASE '$PROJECT_DB
unset PASS

# Push to dokku
git status
git remote add dokku 'dokku@'$DOMAIN':'$PROJECT
git push dokku master --force

# Set address in /etc/hosts
# Access page
