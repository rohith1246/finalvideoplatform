from functools import wraps
from flask import g, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

def require_auth(f):
    @wraps(f)
    @jwt_required()
    def decorated(*args, **kwargs):
        identity = get_jwt_identity()
        claims = get_jwt()
        if not identity:
            return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401
        
        user_data = dict(claims)
        user_data['id'] = identity
        g.current_user = user_data
        return f(*args, **kwargs)
    return decorated
