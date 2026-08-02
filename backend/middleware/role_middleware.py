from functools import wraps
from flask import g, jsonify
from middleware.auth_middleware import require_auth

def require_role(*roles):
    def decorator(f):
        @wraps(f)
        @require_auth
        def decorated_function(*args, **kwargs):
            if g.current_user.get('role') not in roles:
                return jsonify({'status': 'error', 'message': 'Forbidden: insufficient permissions'}), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator
