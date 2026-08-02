from flask import Blueprint, request, jsonify, g
from models import db, Vendor, Candidate
from middleware.role_middleware import require_role
from services.auth_service import AuthService

vendor_bp = Blueprint('vendor', __name__)

@vendor_bp.route('/', methods=['GET'])
@require_role('admin')
def list_vendors():
    vendors = Vendor.query.filter_by(is_active=True).all()
    result = [{
        'id': v.id,
        'vendor_code': v.vendor_code,
        'company_name': v.company_name,
        'email': v.email,
        'total_earnings': v.total_earnings,
        'created_at': v.created_at.isoformat()
    } for v in vendors]
    
    return jsonify({'status': 'success', 'data': result})

@vendor_bp.route('/', methods=['POST'])
@require_role('admin')
def create_vendor():
    data = request.get_json()
    
    required = ['vendor_code', 'company_name', 'contact_person', 'email', 'password']
    if not all(k in data for k in required):
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400
        
    if Vendor.query.filter_by(email=data['email']).first() or Vendor.query.filter_by(vendor_code=data['vendor_code']).first():
        return jsonify({'status': 'error', 'message': 'Vendor already exists'}), 400
        
    hashed_pw = AuthService.hash_password(data['password'])
    vendor = Vendor(
        vendor_code=data['vendor_code'],
        company_name=data['company_name'],
        contact_person=data['contact_person'],
        email=data['email'],
        phone=data.get('phone'),
        password_hash=hashed_pw
    )
    db.session.add(vendor)
    db.session.commit()
    
    return jsonify({'status': 'success', 'data': {'id': vendor.id}}), 201

@vendor_bp.route('/dashboard-stats', methods=['GET'])
@require_role('vendor')
def vendor_stats():
    user = g.current_user
    vendor = Vendor.query.get(user['id'])
    
    if not vendor:
        return jsonify({'status': 'error', 'message': 'Vendor not found'}), 404
        
    candidate_count = Candidate.query.filter_by(vendor_id=vendor.id).count()
    
    return jsonify({
        'status': 'success',
        'data': {
            'total_earnings': vendor.total_earnings,
            'candidate_count': candidate_count
        }
    })

@vendor_bp.route('/<id>', methods=['GET'])
@require_role('admin', 'vendor')
def get_vendor(id):
    vendor = Vendor.query.get(id)
    if not vendor or not vendor.is_active:
        return jsonify({'status': 'error', 'message': 'Vendor not found'}), 404
        
    return jsonify({
        'status': 'success',
        'data': {
            'id': vendor.id,
            'vendor_code': vendor.vendor_code,
            'company_name': vendor.company_name,
            'email': vendor.email,
            'total_earnings': vendor.total_earnings
        }
    })

@vendor_bp.route('/<id>', methods=['PUT'])
@require_role('admin')
def update_vendor(id):
    vendor = Vendor.query.get(id)
    if not vendor:
        return jsonify({'status': 'error', 'message': 'Vendor not found'}), 404
        
    data = request.get_json()
    vendor.company_name = data.get('company_name', vendor.company_name)
    vendor.contact_person = data.get('contact_person', vendor.contact_person)
    vendor.phone = data.get('phone', vendor.phone)
    db.session.commit()
    
    return jsonify({'status': 'success', 'message': 'Vendor updated'})

@vendor_bp.route('/<id>', methods=['DELETE'])
@require_role('admin')
def delete_vendor(id):
    vendor = Vendor.query.get(id)
    if not vendor:
        return jsonify({'status': 'error', 'message': 'Vendor not found'}), 404
        
    vendor.is_active = False
    db.session.commit()
    
    return jsonify({'status': 'success', 'message': 'Vendor deleted'})
