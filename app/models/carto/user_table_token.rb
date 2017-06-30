require 'active_record'
require_dependency 'carto/db/sanitize'

module Carto
  class UserTableToken < ActiveRecord::Base
    belongs_to :table, class_name: Carto::UserTable, inverse_of: :tokens
  end
end
