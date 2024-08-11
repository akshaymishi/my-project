# ProductService API

This project implements a ProductService REST API with JWT authentication and role-based access control. It includes a client application to consume the API.

## Prerequisites

- Python 3.x
- Flask
- Flask-JWT-Extended
- Flask-SQLAlchemy
- Requests

## Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/akshaymishi/my-project
   cd my-project/my-project-2
   ```

2. **Install dependencies:**

    ```pip install -r requirements.txt
    ```

3. **Run the server:**

    ```flask run
    ```

4. **Run the client:**

   Instructions for running the client application go here.

## API Endpoints
POST /login: Authenticate and get a JWT token.
GET /products: Get a list of products (Privileged users only).
GET /products/int:product_id: Get a specific product by ID (Privileged users only).
POST /products: Add a new product (Admin only).

## Usage
1. **Login as a privileged user:**
    ```curl -X POST -H "Content-Type: application/json" -d '{"username": "user", "password": "userpass"}' http://127.0.0.1:5000/login
    ```

2. **Get products:**
    ```curl -X GET -H "Authorization: Bearer <token>" http://127.0.0.1:5000/products
    ```

3. **Get a specific product:**

    ```curl -X GET -H "Authorization: Bearer <token>" http://127.0.0.1:5000/
    ```
4. **Add a new product (Admin only):**
    ```curl -X POST -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"name": "New Product", "price": 10.99}' http://127.0.0.1:5000/products
    ```

## Notes
Ensure that your JWT secret key is secure.
