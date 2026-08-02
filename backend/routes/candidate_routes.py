from flask import Blueprint, request, jsonify, g
from models import db, Candidate, Vendor
from middleware.role_middleware import require_role
from services.auth_service import AuthService

candidate_bp = Blueprint('candidate', __name__)

@candidate_bp.route('/', methods=['GET'])
@require_role('admin', 'vendor')
def list_candidates():
    user = g.current_user
    if user['role'] == 'admin':
        candidates = Candidate.query.all()
    else:
        candidates = Candidate.query.filter_by(vendor_id=user['id']).all()
        
    result = [{
        'id': c.id,
        'full_name': c.full_name,
        'email': c.email,
        'vendor_id': c.vendor_id,
        'is_active': c.is_active,
        'created_at': c.created_at.isoformat()
    } for c in candidates]
    
    return jsonify({'status': 'success', 'data': result})

@candidate_bp.route('/', methods=['POST'])
@require_role('admin', 'vendor')
def create_candidate():
    data = request.get_json()
    user = g.current_user
    
    vendor_id = user['id'] if user['role'] == 'vendor' else data.get('vendor_id')
    
    if not vendor_id:
        return jsonify({'status': 'error', 'message': 'vendor_id required'}), 400
        
    hashed_pw = AuthService.hash_password(data['password'])
    
    candidate = Candidate(
        vendor_id=vendor_id,
        full_name=data['full_name'],
        email=data['email'],
        phone=data.get('phone'),
        password_hash=hashed_pw
    )
    db.session.add(candidate)
    db.session.commit()
    
    return jsonify({'status': 'success', 'data': {'id': candidate.id}}), 201

@candidate_bp.route('/<id>', methods=['GET'])
@require_role('admin', 'vendor')
def get_candidate(id):
    candidate = Candidate.query.get(id)
    if not candidate:
        return jsonify({'status': 'error', 'message': 'Candidate not found'}), 404
        
    return jsonify({
        'status': 'success',
        'data': {
            'id': candidate.id,
            'full_name': candidate.full_name,
            'email': candidate.email,
            'vendor_id': candidate.vendor_id,
            'is_active': candidate.is_active,
            'created_at': candidate.created_at.isoformat()
        }
    })

@candidate_bp.route('/<id>/export-report', methods=['GET'])
@require_role('admin', 'vendor')
def export_report(id):
    # This route is defined here but we will also define it in custom_routes.py with implementation
    # Redirecting logic to custom routes or just stub here to not conflict.
    return jsonify({'status': 'error', 'message': 'Use /api/v1/custom/candidates/<id>/export-report instead'}), 400
