require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      # Allows us to connect to a new database in a clean way
      def change_database!(db)
        if @config[:database] != db
          @config.merge!(database: db)
          clear_query_cache
          reconnect!
        end
      end

      def restore_default_database!
        database = YAML::load_file('config/database.yml')[Rails.env]['database']
        change_database!(database)
      end
    end
  end
end
