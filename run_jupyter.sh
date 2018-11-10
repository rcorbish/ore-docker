#!/bin/sh

# If the example directory exists then leave it alone
# otherwise initialize it.
#
# This allows the example to be saved externally and not overwritten
if [ ! -d ./example ]
then
    cp -r ~/example .
fi

INPWD=${1:-monkeys}
#
# Create a passowrd from the command line
# by default it's monkeys
#
PSWD=$( echo "from notebook.auth import passwd; print( passwd( '${INPWD}' ) )" | ${HOME}/anaconda3/bin/python )

echo "Notebook password is ${INPWD}"
#
# Append the password to the config
#
echo "c.NotebookApp.password = u'${PSWD}'" >> ${HOME}/.jupyter/jupyter_notebook_config.py 

# 
# Run the notebook
#
/root/anaconda3/bin/jupyter-notebook
