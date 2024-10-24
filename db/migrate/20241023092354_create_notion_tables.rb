class CreateNotionTables < ActiveRecord::Migration[8.0]
  def change
    create_table :notion_tables do |t|
      t.references :user, null: false, foreign_key: true
      t.string :database_id,  null: false, default: ''
      t.string :title, null: false, default: 'notion_table'
      t.string :properties, null: false, default: 'properties'

      t.timestamps
    end
  end
end
