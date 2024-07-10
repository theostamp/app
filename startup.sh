#!/bin/bash

# Set environment variables for `postgres` database
export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGDATABASE=postgres
export PGPASSWORD="theo663966@"

# Change ownership and permissions of the wwwroot directory
echo "Changing permissions of /home/site/wwwroot..."
chown -R www-data:www-data /home/site/wwwroot
chmod -R 755 /home/site/wwwroot

# Extract the content of /home/site/wwwroot if it's compressed
if [ -f /home/site/wwwroot/output.tar.gz ]; then
    echo "Extracting /home/site/wwwroot/output.tar.gz..."
    tar -xzvf /home/site/wwwroot/output.tar.gz -C /home/site/wwwroot
fi

# Install requirements
python3 -m pip install -r requirements.txt

echo "Running migrations for postgres database..."
{
    python manage.py makemigrations authentication
    python manage.py makemigrations restaurant_review
    python manage.py makemigrations tenants
    python manage.py makemigrations
    python manage.py migrate tenants --noinput || echo "Migrate tenants failed"
    python manage.py migrate authentication --noinput || echo "Migrate authentication failed"
    python manage.py migrate restaurant_review --noinput || echo "Migrate restaurant_review failed"
    python manage.py migrate_schemas --noinput || echo "Migrate schemas failed"
    python manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}

# Switch to `dign-database` if needed and run migrations
export PGDATABASE=dign-database

echo "Running migrations for dign-database database..."
{
    python manage.py migrate --noinput || echo "Migrate failed"
} || {
    echo "Migrations failed"
    exit 1
}

echo "Creating public tenant and domain..."
python manage.py shell << END
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
python manage.py runserver
