require 'carto/db/migration_helper'

include Carto::Db::MigrationHelper

migration(
    Proc.new do
      create_table :user_table_tokens do
        Uuid        :id, primary_key: true, default: 'uuid_generate_v4()'.lit
        foreign_key :table_id, :user_tables, null: false, type: :uuid, on_delete: :cascade
        Boolean     :write_access, null: false, default: false
        String      :value
        index [:value], :unique =>true
      end
    end,
    Proc.new do
      drop_table :user_table_tokens
    end
)
