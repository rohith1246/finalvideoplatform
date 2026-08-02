from flask import Blueprint, request, jsonify, g
from models import db, Video, QCReview
from middleware.role_middleware import require_role

qc_bp = Blueprint('qc', __name__)

@qc_bp.route('/reviews', methods=['POST'])
@require_role('qc_team')
def submit_review():
    data = request.get_json()
    user = g.current_user
    
    video_id = data.get('video_id')
    video = Video.query.get(video_id)
    
    if not video:
        return jsonify({'status': 'error', 'message': 'Video not found'}), 404
        
    if video.assigned_to != user['id']:
        return jsonify({'status': 'error', 'message': 'Video not assigned to you'}), 403
        
    status = data.get('status')
    
    review = QCReview(
        video_id=video.id,
        reviewer_id=user['id'],
        audio_rating=data.get('audio_rating'),
        lighting_rating=data.get('lighting_rating'),
        framing_rating=data.get('framing_rating'),
        environment_rating=data.get('environment_rating'),
        overall_score=data.get('overall_score'),
        status=status,
        rejection_reason=data.get('rejection_reason'),
        notes=data.get('notes')
    )
    
    if status == 'approved':
        video.status = 'qc_approved'
    else:
        video.status = 'qc_rejected'
        
    db.session.add(review)
    db.session.commit()
    
    return jsonify({'status': 'success', 'message': 'Review submitted'})

@qc_bp.route('/tickets/assigned', methods=['GET'])
@require_role('qc_team')
def assigned_tickets():
    user = g.current_user
    videos = Video.query.filter_by(assigned_to=user['id'], status='pending').all()
    
    result = [{
        'id': v.id,
        'title': v.title,
        'created_at': v.created_at.isoformat()
    } for v in videos]
    
    return jsonify({'status': 'success', 'data': result})

@qc_bp.route('/reviews', methods=['GET'])
@require_role('qc_team', 'admin')
def list_reviews():
    reviews = QCReview.query.all()
    result = [{
        'id': r.id,
        'video_id': r.video_id,
        'reviewer_id': r.reviewer_id,
        'status': r.status,
        'overall_score': r.overall_score
    } for r in reviews]
    
    return jsonify({'status': 'success', 'data': result})
