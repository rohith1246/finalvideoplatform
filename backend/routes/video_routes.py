import os
from werkzeug.utils import secure_filename
from flask import Blueprint, request, jsonify, current_app, send_file, g
from models import db, Video
from middleware.auth_middleware import require_auth
from middleware.role_middleware import require_role

video_bp = Blueprint('video', __name__)

ALLOWED_EXTENSIONS = {'mp4', 'mov', 'avi'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@video_bp.route('/', methods=['GET'])
@require_auth
def list_videos():
    user = g.current_user
    query = Video.query

    candidate_id = request.args.get('candidate_id')
    if candidate_id:
        query = query.filter_by(candidate_id=candidate_id)

    if user['role'] == 'candidate':
        query = query.filter_by(candidate_id=user['id'])
    elif user['role'] == 'vendor':
        query = query.filter_by(vendor_id=user['vendor_code']) # Actually vendor_id
        # Wait, vendor identity has vendor_id or vendor_code, need to match correctly.
        pass

    videos = query.all()
    result = []
    for v in videos:
        result.append({
            'id': v.id,
            'title': v.title,
            'status': v.status,
            'created_at': v.created_at.isoformat(),
            'assigned_to': v.assigned_to
        })

    return jsonify({'status': 'success', 'data': result})

@video_bp.route('/upload', methods=['POST'])
@require_role('candidate')
def upload_video():
    if 'file' not in request.files:
        return jsonify({'status': 'error', 'message': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'status': 'error', 'message': 'No selected file'}), 400
        
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        candidate_id = g.current_user['id']
        vendor_id = g.current_user.get('vendor_id')
        
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], f"{candidate_id}_{filename}")
        file.save(file_path)
        
        new_video = Video(
            candidate_id=candidate_id,
            vendor_id=vendor_id,
            title=request.form.get('title', filename),
            environment_tag=request.form.get('environment_tag'),
            duration_seconds=request.form.get('duration_seconds', 0),
            file_path=file_path
        )
        db.session.add(new_video)
        db.session.commit()
        
        return jsonify({'status': 'success', 'message': 'Video uploaded successfully', 'data': {'id': new_video.id}}), 201
        
    return jsonify({'status': 'error', 'message': 'Invalid file type'}), 400

@video_bp.route('/<id>/stream', methods=['GET'])
@require_auth
def stream_video(id):
    video = Video.query.get(id)
    if not video:
        return jsonify({'status': 'error', 'message': 'Video not found'}), 404
        
    user = g.current_user
    if user['role'] == 'candidate' and video.candidate_id != user['id']:
        return jsonify({'status': 'error', 'message': 'Forbidden'}), 403
        
    return send_file(os.path.abspath(video.file_path))

@video_bp.route('/<id>', methods=['GET'])
@require_auth
def get_video(id):
    video = Video.query.get(id)
    if not video:
        return jsonify({'status': 'error', 'message': 'Video not found'}), 404
        
    return jsonify({
        'status': 'success',
        'data': {
            'id': video.id,
            'title': video.title,
            'status': video.status,
            'file_path': video.file_path,
            'created_at': video.created_at.isoformat()
        }
    })
