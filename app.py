from flask import Flask, render_template, redirect, url_for, request
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Configure database connection
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root@localhost/zum'
db = SQLAlchemy(app)

# Define User model
class User(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  username = db.Column(db.String(255), unique=True, nullable=False)
  email = db.Column(db.String(255), unique=True, nullable=False)
  password_hash = db.Column(db.String(255), nullable=False)

  def set_password(self, password):
    self.password_hash = generate_password_hash(password)

  def check_password(self, password):
    return check_password_hash(self.password_hash, password)

# Register route
@app.route('/register', methods=['GET', 'POST'])
def register():
  if request.method == 'POST':
    username = request.form.get('username')
    email = request.form.get('email')
    password = request.form.get('password')
    # Validate input
    # ...
    # Hash password before saving
    user = User(username=username, email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    return redirect(url_for('login'))
  return render_template('register.html')

# Login route
@app.route('/login', methods=['GET', 'POST'])
def login():
  if request.method == 'POST':
    username = request.form.get('username')
    password = request.form.get('password')
    # Check if user exists and password matches
    user = User.query.filter_by(username=username).first()
    if user and user.check_password(password):
      # Implement session management for login
      return redirect(url_for('home'))
    else:
      # Error message for invalid login
      return render_template('login.html', error="Invalid username or password")
  return render_template('login.html')

# Logout route
@app.route('/logout')
def logout():
  # Implement session management for logout
  return redirect(url_for('login'))

# Home route (protected)
@app.route('/')
def home():
  # Check if user is logged in (redirect to login if not)
  # ...
  return render_template('home.html')

if __name__ == '__main__':
  app.run(debug=True)
