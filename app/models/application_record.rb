class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.admin_database
    "switcharoo_admin_#{Rails.env}"
  end
end
