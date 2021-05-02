# README

The purpose of this example app is to demonstrate live database creation and switching
in Rails. To get bootstrapped:

1. `rails db:setup`
2. `rails db:setup:admin`

The database rake tasks have been modified to allow normal migrations to be run against all
entity databases. A special `:admin` appendage to `db:` tasks will run those tasks on the
admin database.

To create migrations in the admin engine, run your `rails generate` commands from within the
`engines/admin` directory. Since you'll be creating non-namespaced models typically, you'll
need to modify the migration to remove the `admin_` namespace and also update the location of
the model and its location (move it out of `models/admin` and into just `models`).

To run admin migrations, run `rails db:migrate:admin` from the
application root directory.

Using something like `puma-dev` you can configure the application to respond on `switcharoo.test`.

1. `puma-dev link switcharoo`

You can then access the administration interface for adding entities at `admin.switcharoo.test`. This
address is configurable in `config/application.rb`.

When you create a new entity, be sure to make it a subdomain of `switcharoo.test` so that this
Rails application will respond to it. The creation of an entity automatically creates a new
database for the entity and populates it with the schema in `db/schema.rb`.

Over time, you'll be modifying the database structure. Running `rails db:migrate` will modify this
structure for all entities. You'd run this as part of your production deploy process. Since running
migrations also updates `db/schema.rb` new entities created after the migration will have the newer
correct database structure also and won't need migrating.

# Try it out:

1. Hit `admin.switcharoo.test`.
2. Click *New Entity*.
3. Enter a *Name* (e.g. `First Customer`).
4. Enter a *Domain* (e.g. `first.switcharoo.test`)
5. Click *Create Entity*.
6. Click on the domain in the *Entities* list to visit the site.

You can create other entities and you'll notice that the *Things* list will be specific to each
entity as the database is switched at the beginning of the request.

# Key Files and Folders

* `config/extensions/mysql2adapter.rb`
* `config/middleware/host_router.rb`
* `config/middleware/entity_switcher.rb`
* `engines/admin`
* `lib/tasks/databases.rake`
* `engines/admin/lib/tasks/databases.rake`
* `engines/admin/models/entity.rb`
