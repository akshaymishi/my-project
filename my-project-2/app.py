from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///products.db'
app.config['JWT_SECRET_KEY'] = 'your_jwt_secret_key'
db = SQLAlchemy(app)
jwt = JWTManager(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    role = db.Column(db.String(80), nullable=False)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    description = db.Column(db.String(200), nullable=False)
    price = db.Column(db.Float, nullable=False)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data['username']).first()
    if user and check_password_hash(user.password, data['password']):
        access_token = create_access_token(identity={'username': user.username, 'role': user.role})
        return jsonify(access_token=access_token), 200
    return jsonify(msg='Invalid credentials'), 401

@app.route('/products', methods=['GET'])
@jwt_required()
def get_products():
    current_user = get_jwt_identity()
    if current_user['role'] == 'anonymous':
        return jsonify(msg='Access denied'), 403
    products = Product.query.all()
    if not products:
        return jsonify(msg='No products found'), 404
    return jsonify(products=[product.name for product in products]), 200

@app.route('/products/<int:product_id>', methods=['GET'])
@jwt_required()
def get_product(product_id):
    current_user = get_jwt_identity()
    if current_user['role'] == 'anonymous':
        return jsonify(msg='Access denied'), 403
    product = Product.query.get(product_id)
    if not product:
        return jsonify(msg='Product not found'), 404
    return jsonify(name=product.name, description=product.description, price=product.price), 200

@app.route('/products', methods=['POST'])
@jwt_required()
def add_product():
    current_user = get_jwt_identity()
    if current_user['role'] != 'admin':
        return jsonify(msg='Access denied'), 403
    data = request.get_json()
    if Product.query.filter_by(name=data['name']).first():
        return jsonify(msg='Product name must be unique'), 400
    new_product = Product(name=data['name'], description=data['description'], price=data['price'])
    db.session.add(new_product)
    db.session.commit()
    return jsonify(msg='Product is saved successfully'), 201

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)