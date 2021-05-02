# This code allows us to use AR database tasks on engine DB configurations

rule(/^db:(.+):admin$/) do |matched_task|
  admin_dir = Rails.root.join('engines/admin')
  database_yml = admin_dir.join('config/database.yml')

  ActiveRecord::Tasks::DatabaseTasks.root = admin_dir.to_s
  ActiveRecord::Tasks::DatabaseTasks.db_dir = admin_dir.join('db').to_s

  db_namespace = namespace :db do
    task(:load_config).clear
    task(:migrate).clear
    task(:rollback).clear

    task load_config: :environment do
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = YAML.load(ERB.new(database_yml.read).result)
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [admin_dir.join('db/migrate').to_s]
      ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
      ActiveRecord::Base.establish_connection(ActiveRecord::Tasks::DatabaseTasks.env.to_sym)
      ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end

    # Because we've modified the default rake tasks to migrate all entities, we need
    # to reinstate the original tasks here before potentially executing them.
    desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
    task migrate: :load_config do
      ActiveRecord::Tasks::DatabaseTasks.migrate
      db_namespace["_dump"].invoke
    end

    desc "Rolls the schema back to the previous version (specify steps w/ STEP=n)."
    task rollback: :load_config do
      step = ENV["STEP"] ? ENV["STEP"].to_i : 1
      ActiveRecord::Base.connection.migration_context.rollback(step)
      db_namespace["_dump"].invoke
    end

    namespace :test do
      task(:prepare).clear

      # desc 'Load the test schema'
      task prepare: :load_config do
        unless ActiveRecord::Base.configurations.blank?
          db_namespace["test:load"].invoke
        end
      end
    end
  end

  Rails.application.paths.add 'db/seeds.rb', :with => 'engines/admin/db/seeds.rb'

  Rake::Task[matched_task.name.remove(':admin')].invoke
end

namespace :db do
  namespace :test do
    task :prepare do
      system("bin/rake db:test:prepare:admin")
    end
  end
end
