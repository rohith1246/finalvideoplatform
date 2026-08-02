import uuid
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def generate_uuid():
    return str(uuid.uuid4())

class Admin(db.Model):
    __tablename__ = 'admins'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(120), nullable=False)
    role = db.Column(db.String(50), default='admin') # 'admin' or 'qc_team'
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Vendor(db.Model):
    __tablename__ = 'vendors'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    vendor_code = db.Column(db.String(50), unique=True, nullable=False)
    company_name = db.Column(db.String(120), nullable=False)
    contact_person = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(20))
    is_active = db.Column(db.Boolean, default=True)
    total_earnings = db.Column(db.Float, default=0.0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Candidate(db.Model):
    __tablename__ = 'candidates'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    vendor_id = db.Column(db.String(36), db.ForeignKey('vendors.id'))
    full_name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    password_hash = db.Column(db.String(255), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    vendor = db.relationship('Vendor', backref=db.backref('candidates', lazy=True))

class Video(db.Model):
    __tablename__ = 'videos'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    candidate_id = db.Column(db.String(36), db.ForeignKey('candidates.id'))
    vendor_id = db.Column(db.String(36), db.ForeignKey('vendors.id'))
    title = db.Column(db.String(255))
    environment_tag = db.Column(db.String(100))
    duration_seconds = db.Column(db.Integer)
    file_path = db.Column(db.String(500), nullable=False)
    status = db.Column(db.String(50), default='pending') # pending/qc_approved/qc_rejected/admin_approved/admin_rejected
    assigned_to = db.Column(db.String(36), db.ForeignKey('admins.id'), nullable=True) # QC user
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    candidate = db.relationship('Candidate', backref=db.backref('videos', lazy=True))
    vendor = db.relationship('Vendor', backref=db.backref('videos', lazy=True))

class QCReview(db.Model):
    __tablename__ = 'qc_reviews'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    video_id = db.Column(db.String(36), db.ForeignKey('videos.id'))
    reviewer_id = db.Column(db.String(36), db.ForeignKey('admins.id'))
    audio_rating = db.Column(db.Integer)
    lighting_rating = db.Column(db.Integer)
    framing_rating = db.Column(db.Integer)
    environment_rating = db.Column(db.Integer)
    overall_score = db.Column(db.Float)
    status = db.Column(db.String(50))
    rejection_reason = db.Column(db.String(500))
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    video = db.relationship('Video', backref=db.backref('qc_reviews', lazy=True))

class Notification(db.Model):
    __tablename__ = 'notifications'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    user_id = db.Column(db.String(36))
    user_role = db.Column(db.String(50))
    title = db.Column(db.String(255))
    message = db.Column(db.Text)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class DatasetBatch(db.Model):
    __tablename__ = 'dataset_batches'
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    name = db.Column(db.String(255))
    status = db.Column(db.String(50), default='unlocked') # locked/unlocked
    video_count = db.Column(db.Integer, default=0)
    locked_at = db.Column(db.DateTime, nullable=True)
    locked_by = db.Column(db.String(36), db.ForeignKey('admins.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
