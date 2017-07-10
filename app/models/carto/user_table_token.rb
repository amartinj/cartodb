require 'active_record'
require 'digest'
require 'date'
require_dependency 'carto/db/sanitize'

module Carto
  class UserTableToken < ActiveRecord::Base
    belongs_to :table, class_name: Carto::UserTable, inverse_of: :tokens

    def generate_value!
      rnd = Random.new()
      update_attribute(:value, Digest::SHA1.hexdigest("#{table.user.salt}:#{rnd.rand(DateTime.now.strftime('%Q').to_i)}"))
    end
  end
end
