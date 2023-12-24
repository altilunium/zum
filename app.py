from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash



app = Flask(__name__)



# Configure MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root'
app.config['MYSQL_DB'] = 'zum'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

# Secret key for session management (change this to a random, secure key in production)
app.secret_key = 'your_secret_key'

mysql = MySQL(app)


@app.route('/')
def home():
    if 'user_id' in session:
        return  redirect(url_for('view_posts'))
    else:
        return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        existing_user = cur.fetchone()
        cur.close()

        if existing_user:
            flash('Username is already taken. Please choose a different one.', 'danger')
            return redirect(url_for('register'))

        # Hash the password using werkzeug's generate_password_hash
        hashed_password = generate_password_hash(password)

        # Insert the user into the database
        cur = mysql.connection.cursor()
        cur.execute("INSERT INTO users (username, password) VALUES (%s, %s)", (username, hashed_password))
        mysql.connection.commit()
        cur.close()


        cur = mysql.connection.cursor()
        cur.execute("INSERT INTO log (actor, action) VALUES (%s, %s)", (username, "register"))
        mysql.connection.commit()
        cur.close()

        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        cur.close()

        session['user_id'] = user['id']
        session['username'] = user['username']
        session['priv'] = user['priv']

        return redirect(url_for('view_posts'))




    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        cur.close()

        if user and check_password_hash(user['password'], password):
            session['user_id'] = user['id']
            session['username'] = user['username']
            session['priv'] = user['priv']
            flash('Login successful!', 'success')

            cur = mysql.connection.cursor()
            cur.execute("INSERT INTO log (actor, action) VALUES (%s, %s)", (session['username'], "login"))
            mysql.connection.commit()
            cur.close()
            return redirect(url_for('view_posts'))
        else:
            flash('Login failed. Please check your username and password.', 'danger')
    else:
        if 'user_id' in session:
            return  redirect(url_for('view_posts'))
        else:
            return render_template('login.html')


@app.route('/logout', methods=['POST'])
def logout():
    cur = mysql.connection.cursor()
    cur.execute("INSERT INTO log (actor, action) VALUES (%s, %s)", (session['username'], "logout"))
    mysql.connection.commit()
    cur.close()
    session.clear()
    flash('Logout successful!', 'success')
    
    # Get the redirect URL from the form data or use a default
    redirect_url = request.form.get('redirect', url_for('home'))
    
    return redirect(redirect_url)

@app.route('/dashboard')
def dashboard():
    # Check if the user is logged in
    if 'user_id' in session:
        # Fetch user information from the database if needed
        user_id = session['username']
        # Add logic to fetch additional user information if necessary
        return render_template('dashboard.html', user_id=user_id)
    else:
        flash('You need to log in first.', 'danger')
        return redirect(url_for('login'))



@app.route('/create_post', methods=['GET', 'POST'])
def create_post():
    if request.method == 'POST':
        if 'user_id' in session:
            user_id = session['user_id']
            title = request.form['title']
            content = request.form['content']
            parent = request.form['parent']
            grup = request.form['grup']

            cur = mysql.connection.cursor()
            if parent == "null":
                if grup == "null":
                    cur.execute("INSERT INTO blog_posts (user_id, title, content,parent,group_id) VALUES (%s, %s, %s, NULL,NULL)",
                            (user_id, title, content))
                    mysql.connection.commit()
                    cur.close()
                    flash('Blog post created successfully!', 'success')
                    return redirect(url_for('view_posts'))
                else:
                    cur.execute("INSERT INTO blog_posts (user_id, title, content,parent,group_id) VALUES (%s, %s, %s, NULL, %s)",
                            (user_id, title, content,grup))
                    mysql.connection.commit()
                    cur.close()
                    flash('Blog post created successfully!', 'success')
                    return redirect(url_for('view_posts_grup',grup_id=grup))
            else:
                cur.execute("INSERT INTO blog_posts (user_id, title, content,parent) VALUES (%s, %s, %s, %s)",
                            (user_id, title, content,parent))
                mysql.connection.commit()
                cur.close()
                flash('Blog post created successfully!', 'success')
                return redirect(url_for('view_post',post_id=parent))
            
        else:
            flash('You need to log in first.', 'danger')
            return redirect(url_for('login'))

    return render_template('create_post.html')


@app.route('/posts')
def view_posts():
    if 'user_id' in session:
        cur = mysql.connection.cursor()
        cur.execute("SELECT b.id, b.content, b.created_at, u.username , (SELECT COUNT(c.id) FROM blog_posts c WHERE c.parent = b.id) AS com FROM blog_posts b JOIN users u ON b.user_id = u.id WHERE b.parent is null and b.group_id is null ORDER BY b.created_at DESC")
        posts = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.execute("SELECT group_id, COUNT(group_id) AS count FROM blog_posts WHERE group_id IS NOT null GROUP BY group_id ORDER BY count desc;")
        groups = cur.fetchall()
        cur.close()
        return render_template('view_posts.html', posts=posts, user_id=session['username'], groups=groups)
    else:
        flash('You need to log in first.', 'danger')
        return redirect(url_for('login'))


@app.route('/mod')
def mod_dash():
    if 'user_id' in session:
        if session['priv'] == 1:
            cur = mysql.connection.cursor()
            cur.execute("SELECT * FROM blog_posts order by id desc")
            posts = cur.fetchall()
            cur.close()
            return render_template('mod.html',posts=posts)
        else:
            return  redirect(url_for('home'))
    else:
        return redirect(url_for('login'))


@app.route('/delete/<int:post_id>')
def mod_del(post_id):
    if 'user_id' in session:
        if session['priv'] == 1:
            cur = mysql.connection.cursor()
            cur.execute("DELETE FROM blog_posts WHERE id = %s",(post_id,))
            mysql.connection.commit()
            cur.close()
            return "Item deleted successfully"
        else:
            return  redirect(url_for('home'))
    else:
        return redirect(url_for('login'))




@app.route('/grup/<string:grup_id>')
def view_posts_grup(grup_id):
    if 'user_id' in session:
        cur = mysql.connection.cursor()
        cur.execute("SELECT b.id,  b.content, b.created_at, u.username, (SELECT COUNT(c.id) FROM blog_posts c WHERE c.parent = b.id) AS com FROM blog_posts b JOIN users u ON b.user_id = u.id WHERE b.parent is null and b.group_id = %s ORDER BY b.created_at DESC", (grup_id,))
        posts = cur.fetchall()
        cur.close()
        return render_template('view_posts.html', posts=posts, user_id=session['username'], grup=grup_id)
    else:
        cur = mysql.connection.cursor()
        cur.execute("SELECT b.id, b.content, b.created_at, u.username, (SELECT COUNT(c.id) FROM blog_posts c WHERE c.parent = b.id) AS com FROM blog_posts b JOIN users u ON b.user_id = u.id WHERE b.parent is null and b.group_id = %s ORDER BY b.created_at DESC", (grup_id,))
        posts = cur.fetchall()
        cur.close()
        return render_template('view_posts.html', posts=posts, user_id='', grup=grup_id)


@app.route('/post/<int:post_id>')
def view_post(post_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT b.id, b.title, b.content, b.created_at, u.username, b.parent, b.group_id FROM blog_posts b JOIN users u ON b.user_id = u.id WHERE b.id = %s", (post_id,))
    post = cur.fetchone()
    cur.close()

    if post:
        cur = mysql.connection.cursor()
        cur.execute("WITH RECURSIVE content_hierarchy AS (  SELECT id, content, parent, user_id, created_at FROM blog_posts   WHERE id = %s UNION ALL  SELECT t.id, t.content, t.parent, t.user_id, t.created_at FROM blog_posts t INNER JOIN content_hierarchy ch ON t.parent = ch.id ) SELECT c.id , c.content,c.parent, u.username, c.created_at FROM content_hierarchy c JOIN users u ON c.user_id = u.id", (post_id,))
        posta = cur.fetchall()
        cur.close()
        return render_template('view_post.html', post=post, id=post_id, posta=posta)
    else:
        flash('Post not found', 'danger')
        return redirect(url_for('view_posts'))
   


if __name__ == '__main__':
    app.run(debug=True)
