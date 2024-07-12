# Warm

## Project Video Link : https://youtu.be/cpPmBlvtdrs

## Requirement
    
[get-pip.zip](https://github.com/7Har/Warm/files/6250009/get-pip.zip)


    pip install --upgrade pip

    pip install django
     
    pip install psycopg2

    pip install pycryptodome

    pip install django-admin-rangefilter
    
    python -m pip install Pillow  

    pip install django-tenants  

    pip install bootstrap4

    pip install djangorestframework
    
    pip install channels

    <!-- pip install daphne -->
    pip install gunicorn

  pip install -r requirements.txt

## To run the server, run the following command:

    python manage.py makemigrations  
    python manage.py makemigrations authentication
    python manage.py makemigrations admin
    python manage.py makemigrations tables
    python manage.py makemigrations tenants
    python manage.py makemigrations
    python manage.py makemigrations admin 


    python manage.py migrate
    python manage.py migrate tenants
    python manage.py migrate authentication   
    python manage.py migrate admin
    python manage.py migrate tables
    python manage.py migrate_schemas
    python manage.py migrate_schemas --shared 
     
  

    
python manage.py shell

from tenants.models import Tenant, Domain
from django.db import connection

# Δημιουργία ενός δημόσιου ενοικιαστή
tenant = Tenant(name='public_tenant', schema_name='public_tenant')
tenant.save()  # Αυτό θα δημιουργήσει επίσης το σχήμα της βάσης δεδομένων

# Ελέγξτε αν ο ενοικιαστής δημιουργήθηκε επιτυχώς
print(Tenant.objects.all())
from tenants.models import Tenant, Domain

# Ανακτήστε τον ενοικιαστή 'public_tenant'
public_tenant = Tenant.objects.get(name='public_tenant')

# Προσθέστε το domain 'localhost' στον ενοικιαστή 'public_tenant'
Domain.objects.create(domain='localhost', tenant=public_tenant, is_primary=True)

# Επαληθεύστε ότι το νέο domain προστέθηκε σωστά
print(Domain.objects.all())



    python manage.py runserver 8080



python manage.py createsuperuser    
python manage.py create_tenant
python manage.py create_tenant_superuser

python manage.py collectstatic

    daphne -u /tmp/daphne1.sock -b 0.0.0.0 -p 8003 rest_order.asgi:application    





docker system prune -a
docker image prune
docker volume prune

docker-compose logs -f



git init


git add .
git commit -m "[ERROR]  Not Found: /tenants_folders/theo_upload_json/occupied_tables.json/ "
git branch -M main
git remote add origin https://github.com/theostamp/app.git
git push -u origin main 

git push -u origin main --force


Source directory     : /tmp/8dca0e8fedad367
Destination directory: cd /home/site/wwwroot





#εκτελεση στο theo.digns.net

  
python manage.py shell

from tenants.models import Tenant, Domain
from django.db import connection

# Δημιουργία ενός δημόσιου ενοικιαστή
tenant = Tenant(name='public_tenant', schema_name='public_tenant')
tenant.save()  # Αυτό θα δημιουργήσει επίσης το σχήμα της βάσης δεδομένων

# Ελέγξτε αν ο ενοικιαστής δημιουργήθηκε επιτυχώς
print(Tenant.objects.all())
from tenants.models import Tenant, Domain

# Ανακτήστε τον ενοικιαστή 'public_tenant'
public_tenant = Tenant.objects.get(name='public_tenant')

# Προσθέστε το domain 'theo.digns.net' στον ενοικιαστή 'public_tenant'
Domain.objects.create(domain='digns.net', tenant=public_tenant, is_primary=True)

# Επαληθεύστε ότι το νέο domain προστέθηκε σωστά
print(Domain.objects.all())



# Δημιουργία ενός δημόσιου ενοικιαστή
tenant = Tenant(name='public', schema_name='public')
tenant.save()  # Αυτό θα δημιουργήσει επίσης το σχήμα της βάσης δεδομένων

# Ελέγξτε αν ο ενοικιαστής δημιουργήθηκε επιτυχώς
print(Tenant.objects.all())
from tenants.models import Tenant, Domain

# Ανακτήστε τον ενοικιαστή 'public'
public = Tenant.objects.get(name='public')

# Προσθέστε το domain 'theo.digns.net' στον ενοικιαστή 'public'
Domain.objects.create(domain='digns.net', tenant=public, is_primary=True)

# Επαληθεύστε ότι το νέο domain προστέθηκε σωστά
print(Domain.objects.all())








# Δημιουργία ενός δημόσιου ενοικιαστή
tenant = Tenant(name='public', schema_name='public')
tenant.save()  # Αυτό θα δημιουργήσει επίσης το σχήμα της βάσης δεδομένων

# Ελέγξτε αν ο ενοικιαστής δημιουργήθηκε επιτυχώς
print(Tenant.objects.all())
from tenants.models import Tenant, Domain

# Ανακτήστε τον ενοικιαστή 'public'
public = Tenant.objects.get(name='public')

# Προσθέστε το domain 'theo.digns.net' στον ενοικιαστή 'public'
Domain.objects.create(domain='digns.net', tenant=public, is_primary=True)

# Επαληθεύστε ότι το νέο domain προστέθηκε σωστά
print(Domain.objects.all())



export PGHOST=dign-server.postgres.database.azure.com
export PGUSER=yylokmwbnf
export PGPORT=5432
export PGPASSWORD="theo663966@"
export PGDATABASE=postgres

    python manage.py migrate admin zero
    python manage.py migrate tenants zero
    
    python manage.py migrate tables zero
    python manage.py migrate_schemas zero
    python manage.py migrate_schemas --shared  zero
    




    <!-- create sumdomain tennant -->


    from tenants.models import Tenant, Domain

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

# Προσθήκη domains στους υπάρχοντες tenants
add_domain_to_tenant('theo', 'theo', 'theo.digns.net')
add_domain_to_tenant('demo', 'demo', 'demo.digns.net')
add_domain_to_tenant('public_tenant', 'public_tenant', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
add_domain_to_tenant('public_tenant', 'public_tenant', 'digns.net')
add_domain_to_tenant('public', 'public', 'dign-fkh0cyakasa6cqf4.eastus-01.azurewebsites.net')
add_domain_to_tenant('public', 'public', 'digns.net')




