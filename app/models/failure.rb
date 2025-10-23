class Failure < ApplicationRecord
  belongs_to :user

  # バリデーション
  validates :content, presence: true, length: { maximum: 500 }
  validates :priority, presence: true, inclusion: { in: [1, 2, 3] }
  validates :due_date, presence: true

  # 優先度の定数定義
  PRIORITIES = {
    1 => '高',
    2 => '中',
    3 => '低'
  }.freeze

  # スコープ
  scope :completed, -> { where(resolved: true) }
  scope :pending, -> { where(resolved: false) }
  scope :by_priority, -> { order(:priority) }
  scope :by_due_date, -> { order(:due_date) }
  scope :overdue, -> { where('due_date < ? AND resolved = ?', Time.current, false) }

  # インスタンスメソッド
  def priority_text
    PRIORITIES[priority] || '不明'
  end

  def overdue?
    due_date.present? && due_date < Time.current && !resolved?
  end

  def status
    if resolved?
      '完了'
    elsif overdue?
      '期限切れ'
    else
      '進行中'
    end
  end

  def days_remaining
    return 0 if resolved? || due_date.nil?
    ((due_date - Time.current) / 1.day).ceil
  end

  def priority_class
    case priority
    when 1
      'danger'
    when 2
      'warning'
    when 3
      'success'
    else
      'secondary'
    end
  end
end
