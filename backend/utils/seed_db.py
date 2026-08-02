import os
import sys

# Add the parent directory to sys.path so we can import app and models
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import create_app
from models import db, Admin, Vendor, Candidate
from services.auth_service import AuthService

def seed_database():
    app = create_app()
    with app.app_context():
        # Clear existing tables just in case, or you can check if data exists
        db.drop_all()
        db.create_all()

        print("Seeding Admin...")
        admin = Admin(
            email='admin@gmail.com',
            full_name='Super Admin',
            password_hash=AuthService.hash_password('admin123'),
            role='admin'
        )
        db.session.add(admin)

        print("Seeding QC Team...")
        qc_team = Admin(
            email='qcteam@gmail.com',
            full_name='QC Team User',
            password_hash=AuthService.hash_password('qcteam123'),
            role='qc_team'
        )
        db.session.add(qc_team)

        print("Seeding Vendor...")
        vendor = Vendor(
            vendor_code='VEN-001',
            company_name='Vendor Corp',
            contact_person='Vendor Contact',
            email='vendor@gmail.com',
            phone='1234567890',
            password_hash=AuthService.hash_password('vendor123')
        )
        db.session.add(vendor)
        db.session.commit()

        print("Seeding Candidate...")
        candidate = Candidate(
            vendor_id=vendor.id,
            full_name='Test Candidate',
            email='candidate@gmail.com',
            phone='0987654321',
            password_hash=AuthService.hash_password('candidate123')
        )
        db.session.add(candidate)
        db.session.commit()

        print("Database seeded successfully!")

if __name__ == '__main__':
    seed_database()
