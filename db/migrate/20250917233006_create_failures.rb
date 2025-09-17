class CreateFailures < ActiveRecord::Migration[8.0]
  def change
    create_table :failures do |t|
      t.text :content
      t.text :tags
      t.boolean :resolved
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
