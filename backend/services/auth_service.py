import bcrypt
from flask_jwt_extended import create_access_token, create_refresh_token
from models import Admin, Vendor, Candidate

class AuthService:
    @staticmethod
    def hash_password(password):
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')

    @staticmethod
    def verify_password(password, hashed):
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

    @staticmethod
    def generate_tokens(user_id, email, role, name, extra=None):
        claims = {
            'user_id': str(user_id),
            'email': email,
            'role': role,
            'name': name
        }
        if extra:
            claims.update(extra)
        
        # identity must be a string in Flask-JWT-Extended 4.x
        access_token = create_access_token(identity=str(user_id), additional_claims=claims)
        refresh_token = create_refresh_token(identity=str(user_id), additional_claims=claims)
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user_id': str(user_id),
            'email': email,
            'role': role,
            'name': name,
            **(extra or {})
        }

    @staticmethod
    def login(email, password):
        # Check Admin / QC Team
        admin = Admin.query.filter_by(email=email).first()
        if admin and AuthService.verify_password(password, admin.password_hash):
            return AuthService.generate_tokens(admin.id, admin.email, admin.role, admin.full_name)

        # Check Vendor
        vendor = Vendor.query.filter_by(email=email).first()
        if vendor and AuthService.verify_password(password, vendor.password_hash):
            return AuthService.generate_tokens(vendor.id, vendor.email, 'vendor', vendor.company_name, {'vendor_code': vendor.vendor_code})

        # Check Candidate
        candidate = Candidate.query.filter_by(email=email).first()
        if candidate and AuthService.verify_password(password, candidate.password_hash):
            return AuthService.generate_tokens(candidate.id, candidate.email, 'candidate', candidate.full_name, {'vendor_id': candidate.vendor_id})

        return None
