class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :day

  enum category: { day_off: "Day off", paid_dayoff: "Paid Day off", time_off: "Time off"}
  CATEGORY = ["day_off", "paid_dayoff", "time_off"]
  validates :category, presence: true
  validate :preference_count_within_limit, on: :create

  def preference_count_within_limit

    if self.category == 'day_off'
      day_off_limit = self.user.preferences.where(category: "day_off")
      errors.add(:category, "Exceeded day-off limit") if day_off_limit.count >= 3
    end
  end
end
