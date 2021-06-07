#!/bin/bash
# Start a new Python project with a virtual enviroment

## How to use
# To run local stored localy: . new_python_project.sh
# To run file from Github: bash <(curl -s https://raw.githubusercontent.com/dssantos/scripts/master/new_python_project.sh)


PROJECT_NAME=newproject
read -e -i "$PROJECT_NAME" -p "Enter your project name: " input
PROJECT_NAME="${input:-$PROJECT_NAME}"

DEV_FOLDER=${HOME}/dev/python
read -e -i "$DEV_FOLDER" -p "Enter your root devlopment folder path: " input
DEV_FOLDER="${input:-$DEV_FOLDER}"

GIT_REPO=https://github.com/dssantos/${PROJECT_NAME}
read -e -i "$GIT_REPO" -p "Enter your url project on Github: " input
GIT_REPO="${input:-$GIT_REPO}"


mkdir -p ${DEV_FOLDER}/${PROJECT_NAME}
cd ${DEV_FOLDER}/${PROJECT_NAME}
python -m venv .${PROJECT_NAME}
source .${PROJECT_NAME}/bin/activate
python -m pip install -U pip

echo -e """
# ${PROJECT_NAME}

## How to dev

### Linux
```bash
git clone ${GIT_REPO} ${PROJECT_NAME}
cd ${PROJECT_NAME}
python -m venv .${PROJECT_NAME}
source .${PROJECT_NAME}/bin/activate
python -m pip install -U pip
pip install -r requirements.txt
```

### Windows (Powershell)
```bash
git clone ${GIT_REPO} ${PROJECT_NAME}
cd ${PROJECT_NAME}
python -m venv .${PROJECT_NAME}
Set-ExecutionPolicy Unrestricted -Scope Process -force
.\.${PROJECT_NAME}\Scripts\activate
python -m pip install -U pip
pip install -r requirements.txt
```

## How to deploy

## How to use

""" > README.md


echo -e """
.${PROJECT_NAME}/
.env
*.sqlite3
*.pyc
__pycache__
staticfiles
.vscode
""" > .gitignore


echo -e """
""" > requirements.txt

