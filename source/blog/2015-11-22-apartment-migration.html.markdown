---
title: apartment-migration
published: false
date: 2015-11-22 02:20 UTC
tags: rails, postgres, apartment
---
If you ever need to migrate from a single-tenanted rails app to an
apartment-based multitenanted app, here's one way to make `pg_dump` and
`pg_restore` do all of the work.

This is assuming:

* There are multiple instance of the rails app
* Each instance has its own postgres db
* The new solution will have all the old data on a single database
* The multitenanted app will use postgres' schemas and not foreign-key scoping.

Assumptions:

* There is a backup of each database locally
* The app is ready for apartment, it just needs the old data to be imported.

Let's say we have an app with 3 instance and we want to move to an schema-scoped
multitenancy app. First, we get our app configured for apartment and create our
tenants:

```ruby
%w(tenant1, tenant2, tenant3).each do |tenant|
  Apartment::Tenant.create tenant
end
```

This will create a schema for each tenant and run any migrations.

Next, we'll get a script to import our data from local backups to the new
database.

```ruby
%x(psql #{new_database_name} -c 'alter schema public rename to public_save;')

tenants.each do |database|
  %x(psql #{new_database_name} -c 'alter schema \"#{database}\" rename to public;')
  %x(pg_restore --verbose --no-acl --no-owner --data-only -h localhost -d
    #{new_database_name} ../backups/PostgreSQL-#{database}.sql
    --disable-triggers -j 5)
  %x(psql #{new_database_name} -c 'alter schema public rename to
    \"#{database}\";')
  end
  %x(psql #{new_database_name} -c 'alter schema public_save rename to
    public;')
```

I couldn't find an easy way to import to a selected schema so this script first
renames the `public` schema for safekeeping.

Then, it steps through each `Apartment::Tenant` and renames the tenant's schema
to `public`, which allows `pg_restore` to work correctly. Since the schema has
already had all of it's migrations run, it's run with the `--data-only` flag to
just import data.

Since `pg_restore` only works on the `public_schema`, after each tenant is
imported, we rename it to its correct name so that apartment can work correctly
and then rename the next tenant in the loop to `public` and repeat the process.

At the end, the old `public` schema is correctly renamed and now all of the
databases are running on a single postgres instance. cool!
