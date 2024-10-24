class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notion_access_token, :string
    add_column :users, :name, :string, null: false, default: 'user'
  end
end
