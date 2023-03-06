class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :day

  enum category: %i[day_off paid_dayoff time_off]

  validates :category, presence: true
end
