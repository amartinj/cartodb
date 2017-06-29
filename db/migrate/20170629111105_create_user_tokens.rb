require 'carto/db/migration_helper'

include Carto::Db::MigrationHelper

migration(
    Proc.new do
      create_table :user_table_tokens do
        primary_key :id
        String :value
        Boolean :write
        foreign_key :user_table_id, :user_table
        index :value, :unique=>true
      end
    end,
    Proc.new do
      drop_table :user_table_tokens
    end
)



