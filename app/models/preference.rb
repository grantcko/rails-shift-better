class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :day

  enum category: %i[Day-off Paid-Dayoff Time-off]

  validates :category, presence: true
end
