class Entity < ApplicationRecord
  self.table_name =  "#{admin_database}.entities"

  validates_presence_of :name, :database, :domain
  validates :domain, exclusion: { in: [
    Rails.application.config.admin_address, Rails.application.config.assets_address
  ] }
  validates :database, exclusion: { in: [self.admin_database] }

  before_validation :set_database, :on => :create
  after_create :create_database, :seed_entity
  after_destroy :destroy_database

  def set_database
    self.database = "switcharoo_#{Digest::SHA1.hexdigest(domain)[0..15]}" if domain
  end

  def create_database
    ActiveRecord::Base.connection.create_database database,
      charset: 'utf8mb4', collation: 'utf8mb4_unicode_ci'
  end

  def destroy_database
    ActiveRecord::Base.connection.drop_database database
  end

  def seed_entity
    ActiveRecord::Base.connection.change_database! database

    ActiveRecord::Schema.verbose = false
    load("db/schema.rb")

    ActiveRecord::Base.connection.restore_default_database!
  end
end
