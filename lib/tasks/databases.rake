db_namespace = namespace :db do
  task(:migrate).clear
  task(:rollback).clear

  desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
  task migrate: :load_config do
    ActiveRecord::Tasks::DatabaseTasks.migrate
    db_namespace["_dump"].invoke

    with_each_entity do
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n)."
  task rollback: :load_config do
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1
    ActiveRecord::Base.connection.migration_context.rollback(step)
    db_namespace["_dump"].invoke

    with_each_entity do
      ActiveRecord::Base.connection.migration_context.rollback(step)
    end
  end

  private

  def with_each_entity
    Entity.all.each do |entity|
      begin
        ActiveRecord::Base.connection.change_database!(entity.database)
        puts "Migrating #{entity.name} (#{entity.database})"
        yield
      rescue Mysql2::Error
        puts "ERROR Migrating #{entity.name} (#{entity.database}): Database doesn't exist!"
      end
    end
  end
end
