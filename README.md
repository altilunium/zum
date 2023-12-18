![image](https://github.com/altilunium/zum/assets/70379302/24eddc99-0753-42f5-8113-3eca66ef9349)

# zum

Yet another forum software written in Flask. Markdown rendering, comment tree and subcategories.


### Deployment guide

1. `pip install flask`
2. `pip install flask-mysqldb`
3. Install MySQL, [set the user password](https://stackoverflow.com/questions/41645309/mysql-error-access-denied-for-user-rootlocalhost)
 (for example : "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpasswordhere';"), dump the a.sql
4. Open app.py, configure the MySQL connection, test run (python3 app.py).
5. `sudo apt install apache2`
6. sudo apt-get install [libapache2-mod-wsgi-py3](https://stackoverflow.com/questions/2081776/couldnt-find-package-libapache2-mod-wsgi)
7. Copy this project directory to "/var/www/html"
8. Open `/etc/apache2/sites-enabled/000-default.conf`. Below the "DocumentRoot" line, add this code

```
WSGIDaemonProcess zum threads=5
WSGIScriptAlias / /var/www/html/zum/app.wsgi
 
<Directory zum>
    WSGIProcessGroup zum
    WSGIApplicationGroup %{GLOBAL}
    Order deny,allow
    Allow from all
</Directory>
```

Finally, restart apache.

`sudo service apache2 restart`


### Known errors during deployment

#### MySQL env vars
"Exception: Can not find valid pkg-config name. Specify MYSQLCLIENT_CFLAGS and MYSQLCLIENT_LDFLAGS env vars manually" during `pip install flask-mysqldb`.

[Solution](https://stackoverflow.com/questions/76875507/can-not-install-apache-airflow-providers-mysql-pkg-config-error) :

```
mysql_config --cflags
mysql_config --libs
export MYSQLCLIENT_CFLAGS="output of mysql_config --cflags"
export MYSQLCLIENT_LDFLAGS="output of mysql_config --libs"
```

#### app ctx stack
"ImportError: cannot import name '_app_ctx_stack' from 'flask.ctx'" when running the app.py

[Solution](https://stackoverflow.com/questions/73340344/cannot-use-module-aioflaskpython-importerror-cannot-import-name-app-ctx-st) :

```
pip uninstall flask
pip install flask==2.1.3
```

#### werkzeug.urls
"ImportError: cannot import name 'url_quote' from 'werkzeug.urls'" when running the app.py.

[Solution](https://stackoverflow.com/questions/77213053/why-did-flask-start-failing-with-importerror-cannot-import-name-url-quote-fr) :

```
pip uninstall werkzeug
pip install werkzeug==2.2.2
```
