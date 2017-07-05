require 'active_record'
require 'digest'
require 'date'
require_dependency 'carto/db/sanitize'

module Carto
  class UserTableToken < ActiveRecord::Base
    belongs_to :table, class_name: Carto::UserTable, inverse_of: :tokens

    def generate_value!
      update_attribute(:value, Digest::SHA1.hexdigest("#{table.user.salt}:#{DateTime.now.strftime('%Q')}"))
    end
  end
end
