from flask import Blueprint, request, jsonify
from models import db, Admin, Video, Vendor, Candidate
from middleware.role_middleware import require_role
from services.auth_service import AuthService

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/dashboard-stats', methods=['GET'])
@require_role('admin')
def get_stats():
    total_videos = Video.query.count()
    approved_videos = Video.query.filter_by(status='admin_approved').count()
    total_vendors = Vendor.query.count()
    total_candidates = Candidate.query.count()
    
    return jsonify({
        'status': 'success',
        'data': {
            'total_videos': total_videos,
            'approved_videos': approved_videos,
            'total_vendors': total_vendors,
            'total_candidates': total_candidates
        }
    })

@admin_bp.route('/videos/dispatch-qc', methods=['POST'])
@require_role('admin')
def dispatch_qc():
    pending_videos = Video.query.filter_by(status='pending', assigned_to=None).all()
    qc_users = Admin.query.filter_by(role='qc_team', is_active=True).all()
    
    if not qc_users:
        return jsonify({'status': 'error', 'message': 'No QC team members available'}), 400
        
    if not pending_videos:
        return jsonify({'status': 'success', 'message': 'No pending videos to dispatch'})
        
    qc_count = len(qc_users)
    for idx, video in enumerate(pending_videos):
        qc_user = qc_users[idx % qc_count]
        video.assigned_to = qc_user.id
        
    db.session.commit()
    return jsonify({'status': 'success', 'message': f'Dispatched {len(pending_videos)} videos'})

@admin_bp.route('/videos/<id>/approve', methods=['POST'])
@require_role('admin')
def approve_video(id):
    video = Video.query.get(id)
    if not video:
        return jsonify({'status': 'error', 'message': 'Video not found'}), 404
        
    video.status = 'admin_approved'
    db.session.commit()
    return jsonify({'status': 'success', 'message': 'Video approved'})

@admin_bp.route('/videos/<id>/reject', methods=['POST'])
@require_role('admin')
def reject_video(id):
    video = Video.query.get(id)
    if not video:
        return jsonify({'status': 'error', 'message': 'Video not found'}), 404
        
    data = request.get_json() or {}
    reason = data.get('reason', 'No reason provided')
    
    video.status = 'admin_rejected'
    db.session.commit()
    return jsonify({'status': 'success', 'message': 'Video rejected', 'reason': reason})

@admin_bp.route('/', methods=['GET'])
@require_role('admin')
def list_admins():
    admins = Admin.query.all()
    result = [{
        'id': a.id,
        'email': a.email,
        'full_name': a.full_name,
        'role': a.role,
        'created_at': a.created_at.isoformat()
    } for a in admins]
    return jsonify({'status': 'success', 'data': result})

@admin_bp.route('/', methods=['POST'])
@require_role('admin')
def create_admin():
    data = request.get_json()
    if Admin.query.filter_by(email=data['email']).first():
        return jsonify({'status': 'error', 'message': 'Email exists'}), 400
        
    hashed_pw = AuthService.hash_password(data['password'])
    admin = Admin(
        email=data['email'],
        full_name=data['full_name'],
        password_hash=hashed_pw,
        role=data.get('role', 'admin')
    )
    db.session.add(admin)
    db.session.commit()
    return jsonify({'status': 'success', 'data': {'id': admin.id}}), 201
