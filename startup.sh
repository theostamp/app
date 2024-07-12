#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Set environment variables for `postgres` database
export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGPASSWORD="theo663966@"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to install requirements
install_requirements() {
    log_message "Checking for requirements.txt..."
    if [ -f /home/site/wwwroot/requirements.txt ]; then
        log_message "Installing requirements..."
        python3 -m pip install -r /home/site/wwwroot/requirements.txt || { log_message "Failed to install requirements"; exit 1; }
    else
        log_message "requirements.txt not found."
        exit 1
    fi
}

# Function to run migrations
run_migrations() {
    log_message "Running migrations for postgres database..."
    {
        python /home/site/wwwroot/manage.py makemigrations authentication
        python /home/site/wwwroot/manage.py makemigrations admin
        python /home/site/wwwroot/manage.py makemigrations restaurant_review
        python /home/site/wwwroot/manage.py makemigrations tenants
        python /home/site/wwwroot/manage.py makemigrations
        python /home/site/wwwroot/manage.py migrate tenants --noinput || log_message "Migrate tenants failed"
        python /home/site/wwwroot/manage.py migrate authentication --noinput || log_message "Migrate authentication failed"
        python /home/site/wwwroot/manage.py migrate admin --noinput || log_message "Migrate admin failed"
        python /home/site/wwwroot/manage.py migrate restaurant_review --noinput || log_message "Migrate restaurant_review failed"
        python /home/site/wwwroot/manage.py migrate_schemas --noinput || log_message "Migrate schemas failed"
        python /home/site/wwwroot/manage.py migrate --noinput || log_message "Migrate failed"
    } || {
        log_message "Migrations failed"
        exit 1
    }
}

# Function to run dign-database migrations
run_dign_migrations() {
    export PGDATABASE=dign-database
    log_message "Running migrations for dign-database database..."
    {
        python /home/site/wwwroot/manage.py migrate --noinput || log_message "Migrate failed"
    } || {
        log_message "Migrations failed"
        exit 1
    }
}

# Function to create tenants and domains
create_tenants_and_domains() {
    log_message "Creating public tenant and domain..."
    python /home/site/wwwroot/manage.py shell << END
from tenants.models import Tenant, Domain

def create_tenant(name, schema_name, domain_name):
    try:
        tenant = Tenant(name=name, schema_name=schema_name)
        tenant.save()
        Domain.objects.create(domain=domain_name, tenant=tenant, is_primary=True)
    except Exception as e:
        print(f"Error creating tenant or domain {domain_name}: {e}")

def add_domain_to_tenant(tenant_name, schema_name, domain_name):
    try:
        tenant = Tenant.objects.get(name=tenant_name, schema_name=schema_name)
        if not Domain.objects.filter(domain=domain_name, tenant=tenant).exists():
            Domain.objects.create(domain=domain_name, tenant=tenant, is_primary=True)
            print(f"Successfully added domain {domain_name} to tenant {tenant_name}")
        else:
            print(f"Domain {domain_name} already exists for tenant {tenant_name}")
    except Tenant.DoesNotExist:
        print(f"Tenant {tenant_name} with schema {schema_name} does not exist.")
    except Exception as e:
        print(f"Error adding domain {domain_name} to tenant {tenant_name}: {e}")

# Δημιουργία tenants και domains
create_tenant('public_tenant', 'public_tenant', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
add_domain_to_tenant('public_tenant', 'public_tenant', 'digns.net')
add_domain_to_tenant('public', 'public', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
add_domain_to_tenant('public', 'public', 'digns.net')
add_domain_to_tenant('theo', 'theo', 'theo.digns.net')
add_domain_to_tenant('demo', 'demo', 'demo.digns.net')

END
}

# Function to start the gunicorn server
start_gunicorn() {
    log_message "Starting gunicorn server..."
    gunicorn --workers 2 --threads 4 --timeout 60 --access-logfile '-' --error-logfile '-' --bind=0.0.0.0:8000 azureproject.wsgi
}

# Main script execution
log_message "Script execution started"
install_requirements
run_migrations
run_dign_migrations
create_tenants_and_domains
start_gunicorn
log_message "Script execution finished"
