from flask import Blueprint, request, jsonify
from flask_jwt_extended import get_jwt_identity, jwt_required
from services.auth_service import AuthService
from models import db, Candidate, Vendor

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json(silent=True, force=True) or request.form or {}
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'status': 'error', 'message': 'Email and password are required'}), 400

    tokens = AuthService.login(email, password)
    if not tokens:
        return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 401

    return jsonify({
        'status': 'success',
        'data': tokens
    })

@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json(silent=True, force=True) or request.form or {}
    vendor_code = data.get('vendor_code')
    full_name = data.get('full_name')
    email = data.get('email')
    password = data.get('password')
    phone = data.get('phone')

    if not all([vendor_code, full_name, email, password]):
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400

    vendor = Vendor.query.filter_by(vendor_code=vendor_code).first()
    if not vendor:
        return jsonify({'status': 'error', 'message': 'Invalid vendor code'}), 400

    if Candidate.query.filter_by(email=email).first():
        return jsonify({'status': 'error', 'message': 'Email already exists'}), 400

    hashed_password = AuthService.hash_password(password)
    
    new_candidate = Candidate(
        vendor_id=vendor.id,
        full_name=full_name,
        email=email,
        phone=phone,
        password_hash=hashed_password
    )
    
    db.session.add(new_candidate)
    db.session.commit()

    return jsonify({'status': 'success', 'message': 'Candidate registered successfully'}), 201

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    current_user = get_jwt_identity()
    new_tokens = AuthService.generate_tokens(
        current_user['id'],
        current_user['email'],
        current_user['role'],
        current_user['name']
    )
    return jsonify({
        'status': 'success',
        'data': {'access_token': new_tokens['access_token']}
    })

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    return jsonify({'status': 'success', 'message': 'Logged out successfully'}), 200
