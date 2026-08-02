import os
from io import BytesIO
from flask import Blueprint, request, jsonify, g, send_file
from models import db, Candidate, DatasetBatch
from middleware.role_middleware import require_role
from reportlab.pdfgen import canvas

custom_bp = Blueprint('custom', __name__)

@custom_bp.route('/candidates/<id>/export-report', methods=['GET'])
@require_role('admin', 'vendor')
def export_candidate_report(id):
    candidate = Candidate.query.get(id)
    if not candidate:
        return jsonify({'status': 'error', 'message': 'Candidate not found'}), 404
        
    buffer = BytesIO()
    p = canvas.Canvas(buffer)
    p.drawString(100, 800, f"Candidate Report: {candidate.full_name}")
    p.drawString(100, 780, f"Email: {candidate.email}")
    p.drawString(100, 760, f"Vendor ID: {candidate.vendor_id}")
    p.drawString(100, 740, f"Status: {'Active' if candidate.is_active else 'Inactive'}")
    
    # Add video stats if needed
    p.showPage()
    p.save()
    
    buffer.seek(0)
    return send_file(buffer, as_attachment=True, download_name=f"report_{candidate.id}.pdf", mimetype='application/pdf')

@custom_bp.route('/dataset-batch-lock', methods=['POST'])
@require_role('admin')
def lock_dataset_batch():
    data = request.get_json()
    name = data.get('name')
    if not name:
        return jsonify({'status': 'error', 'message': 'Batch name required'}), 400
        
    batch = DatasetBatch.query.filter_by(name=name).first()
    if not batch:
        batch = DatasetBatch(name=name, status='locked', locked_by=g.current_user['id'])
        db.session.add(batch)
    else:
        batch.status = 'locked'
        batch.locked_by = g.current_user['id']
        
    db.session.commit()
    
    return jsonify({'status': 'success', 'message': f'Dataset batch {name} locked successfully'})
