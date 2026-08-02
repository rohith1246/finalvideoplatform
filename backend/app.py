import os
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from models import db
from routes.auth_routes import auth_bp
from routes.video_routes import video_bp
from routes.vendor_routes import vendor_bp
from routes.candidate_routes import candidate_bp
from routes.admin_routes import admin_bp
from routes.qc_routes import qc_bp
from routes.custom_routes import custom_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Initialize extensions
    CORS(app, resources={r"/api/*": {"origins": app.config['CORS_ORIGINS']}})
    db.init_app(app)
    jwt = JWTManager(app)

    # Ensure upload folder exists
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(video_bp, url_prefix='/api/v1/videos')
    app.register_blueprint(vendor_bp, url_prefix='/api/v1/vendors')
    app.register_blueprint(candidate_bp, url_prefix='/api/v1/candidates')
    app.register_blueprint(admin_bp, url_prefix='/api/v1/admins')
    app.register_blueprint(qc_bp, url_prefix='/api/v1/qc')
    app.register_blueprint(custom_bp, url_prefix='/api/v1/custom')

    @app.route('/health')
    def health():
        return jsonify({'status': 'success', 'message': 'API is running'})

    @app.route('/api/v1')
    def api_index():
        return jsonify({'status': 'success', 'message': 'Video Data Collection Platform API v1'})

    @app.errorhandler(404)
    def not_found(e):
        return jsonify({'status': 'error', 'message': 'Resource not found'}), 404

    @app.errorhandler(500)
    def internal_error(e):
        return jsonify({'status': 'error', 'message': 'Internal server error'}), 500

    with app.app_context():
        db.create_all()

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=app.config['PORT'])

# Module-level app instance for Gunicorn (gunicorn app:app)
app = create_app()
