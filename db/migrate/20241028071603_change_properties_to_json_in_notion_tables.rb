class ChangePropertiesToJsonInNotionTables < ActiveRecord::Migration[6.1]
  def up
    remove_column :notion_tables, :properties
    add_column :notion_tables, :properties, :jsonb, default: {}
  end

  def down
    remove_column :notion_tables, :properties
    add_column :notion_tables, :properties, :string # Adjust this to your previous data type
  end
end
