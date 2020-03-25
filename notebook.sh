#!/bin/bash
# configure Jupyter notebook
jupyter notebook --generate-config -y

echo "
c = get_config()

c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 9999
c.NotebookApp.token = ''
import os
c.NotebookApp.notebook_dir = os.path.expanduser('~')
" >> .jupyter/jupyter_notebook_config.py

# configure Python for Spark workers
echo 'export PYSPARK_PYTHON=$HOME/anaconda3/bin/python' >> spark/conf/spark-env.sh

sip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
PYSPARK_DRIVER_PYTHON=jupyter PYSPARK_DRIVER_PYTHON_OPTS=notebook ./spark/bin/pyspark --master spark://$sip:7077 &
