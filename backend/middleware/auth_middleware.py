from functools import wraps
from flask import g, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

def require_auth(f):
    @wraps(f)
    @jwt_required()
    def decorated(*args, **kwargs):
        current_user = get_jwt_identity()
        if not current_user:
            return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401
        g.current_user = current_user
        return f(*args, **kwargs)
    return decorated
