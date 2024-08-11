import requests
import json

BASE_URL = 'http://127.0.0.1:5000'

def login(username, password):
    response = requests.post(f'{BASE_URL}/login', json={'username': username, 'password': password})
    if response.status_code == 200:
        return response.json()['access_token']
    print(f"Error: {response.status_code}, {response.json()['msg']}")
    return None

def get_products(token):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(f'{BASE_URL}/products', headers=headers)
    if response.status_code == 200:
        print(response.json())
    else:
        print(f"Error: {response.status_code}, {response.json()['msg']}")

def get_product(token, product_id):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(f'{BASE_URL}/products/{product_id}', headers=headers)
    if response.status_code == 200:
        product = response.json()
        with open('product.json', 'w') as f:
            json.dump(product, f)
        print(product)
    else:
        print(f"Error: {response.status_code}, {response.json()['msg']}")

def add_product(token, product):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.post(f'{BASE_URL}/products', json=product, headers=headers)
    if response.status_code == 201:
        print(response.json()['msg'])
    else:
        print(f"Error: {response.status_code}, {response.json()['msg']}")

if __name__ == '__main__':
    # Login as privileged user
    token = login('user', 'userpass')
    if token:
        get_products(token)
        get_product(token, 1)
        add_product(token, {"name": "New Product", "description": "Description", "price": 10.0})

    # Login as admin user
    token = login('admin', 'adminpass')
    if token:
        add_product(token, {"name": "Unique Product", "description": "Description", "price": 20.0})