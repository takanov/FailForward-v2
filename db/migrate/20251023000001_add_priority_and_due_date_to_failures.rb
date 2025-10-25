class AddPriorityAndDueDateToFailures < ActiveRecord::Migration[8.0]
  def change
    add_column :failures, :priority, :integer, default: 2
    add_column :failures, :due_date, :datetime

    # インデックスを追加
    add_index :failures, :priority
    add_index :failures, :due_date
    add_index :failures, :resolved
  end
end

