#!/bin/bash

# Set environment variables for `postgres` database
export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGPASSWORD="theo663966@"
export PGDATABASE=postgres

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
    python /home/site/wwwroot/manage.py makemigrations admin
    python /home/site/wwwroot/manage.py makemigrations restaurant_review
    python /home/site/wwwroot/manage.py makemigrations tenants
    python /home/site/wwwroot/manage.py makemigrations
    python /home/site/wwwroot/manage.py migrate tenants --noinput || echo "Migrate tenants failed"
    python /home/site/wwwroot/manage.py migrate authentication --noinput || echo "Migrate authentication failed"
    python /home/site/wwwroot/manage.py migrate admin --noinput || echo "Migrate admin failed"
    python /home/site/wwwroot/manage.py migrate restaurant_review --noinput || echo "Migrate restaurant_review failed"
    python /home/site/wwwroot/manage.py migrate_schemas --noinput || echo "Migrate schemas failed"
    python /home/site/wwwroot/manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}



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

# Function to create tenant and domain
def create_tenant(name, schema_name, domain_name):
    try:
        tenant = Tenant(name=name, schema_name=schema_name)
        tenant.save()
        Domain.objects.create(domain=domain_name, tenant=tenant, is_primary=True)
    except Exception as e:
        print(f"Error creating tenant or domain {domain_name}: {e}")

# Create public_tenant and public tenants with both domains
create_tenant('public_tenant', 'public_tenant', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
create_tenant('public_tenant', 'public_tenant', 'theo.digns.net')
create_tenant('public_tenant', 'public_tenant', 'demo.digns.net')
create_tenant('public', 'public', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
create_tenant('public', 'public', 'theo.digns.net')
create_tenant('public', 'public', 'demo.digns.net')

END






# Switch to `dign-database` if needed and run migrations
export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGPASSWORD="theo663966@"
export PGDATABASE=dign-database



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
    python /home/site/wwwroot/manage.py makemigrations admin
    python /home/site/wwwroot/manage.py makemigrations restaurant_review
    python /home/site/wwwroot/manage.py makemigrations tenants
    python /home/site/wwwroot/manage.py makemigrations
    python /home/site/wwwroot/manage.py migrate tenants --noinput || echo "Migrate tenants failed"
    python /home/site/wwwroot/manage.py migrate authentication --noinput || echo "Migrate authentication failed"
    python /home/site/wwwroot/manage.py migrate admin --noinput || echo "Migrate admin failed"
    python /home/site/wwwroot/manage.py migrate restaurant_review --noinput || echo "Migrate restaurant_review failed"
    python /home/site/wwwroot/manage.py migrate_schemas --noinput || echo "Migrate schemas failed"
    python /home/site/wwwroot/manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}



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

# Function to create tenant and domain
def create_tenant(name, schema_name, domain_name):
    try:
        tenant = Tenant(name=name, schema_name=schema_name)
        tenant.save()
        Domain.objects.create(domain=domain_name, tenant=tenant, is_primary=True)
    except Exception as e:
        print(f"Error creating tenant or domain {domain_name}: {e}")

# Create public_tenant and public tenants with both domains
create_tenant('public_tenant', 'public_tenant', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
create_tenant('public_tenant', 'public_tenant', 'theo.digns.net')
create_tenant('public_tenant', 'public_tenant', 'demo.digns.net')
create_tenant('public', 'public', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
create_tenant('public', 'public', 'theo.digns.net')
create_tenant('public', 'public', 'demo.digns.net')

END




echo "Starting gunicorn server..."
gunicorn --workers 2 --threads 4 --timeout 60 --access-logfile '-' --error-logfile '-' --bind=0.0.0.0:8000 azureproject.wsgi
