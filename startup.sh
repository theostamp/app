#!/bin/bash

# Set environment variables for `postgres` database
export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGDATABASE=postgres
export PGPASSWORD="theo663966@"

try:
    tenant = Tenant(name='public', schema_name='public')
    tenant.save()
except Exception as e:
    print(f"Error creating tenant: {e}")

try:
    public = Tenant.objects.get(name='public')
    Domain.objects.create(domain='digns.net', tenant=public, is_primary=True)
except Exception as e:
    print(f"Error creating domain: {e}")
# Check if requirements.txt exists
if [ -f /home/site/wwwroot/requirements.txt ]; then
    # Install requirements
    python3 -m pip install -r /home/site/wwwroot/requirements.txt || { echo "Failed to install requirements"; exit 1; }
else
    echo "requirements.txt not found."
    exit 1
fi

echo "Running migrations for postgres database..."
{
    python /home/site/wwwroot/manage.py makemigrations authentication
    python /home/site/wwwroot/manage.py makemigrations restaurant_review
    python /home/site/wwwroot/manage.py makemigrations tenants
    python /home/site/wwwroot/manage.py makemigrations
    python /home/site/wwwroot/manage.py migrate tenants --noinput || echo "Migrate tenants failed"
    python /home/site/wwwroot/manage.py migrate authentication --noinput || echo "Migrate authentication failed"
    python /home/site/wwwroot/manage.py migrate restaurant_review --noinput || echo "Migrate restaurant_review failed"
    python /home/site/wwwroot/manage.py migrate_schemas --noinput || echo "Migrate schemas failed"
    python /home/site/wwwroot/manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}

# Switch to `dign-database` if needed and run migrations
export PGDATABASE=dign-database

echo "Running migrations for dign-database database..."
{
    python /home/site/wwwroot/manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}

echo "Creating public tenant and domain..."
python /home/site/wwwroot/manage.py shell << END
from tenants.models import Tenant, Domain
from django.db import connection

try:
    tenant = Tenant(name='public_tenant', schema_name='public_tenant')
    tenant.save()
except Exception as e:
    print(f"Error creating tenant: {e}")

try:
    public_tenant = Tenant.objects.get(name='public_tenant')
    Domain.objects.create(domain='dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net', tenant=public_tenant, is_primary=True)
except Exception as e:
    print(f"Error creating domain: {e}")

try:
    tenant = Tenant(name='public', schema_name='public')
    tenant.save()
except Exception as e:
    print(f"Error creating tenant: {e}")

try:
    public = Tenant.objects.get(name='public')
    Domain.objects.create(domain='dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net', tenant=public, is_primary=True)
except Exception as e:
    print(f"Error creating domain: {e}")

END

echo "Starting gunicorn server..."
gunicorn --workers 2 --threads 4 --timeout 60 --access-logfile '-' --error-logfile '-' --bind=0.0.0.0:8000 azureproject.wsgi
