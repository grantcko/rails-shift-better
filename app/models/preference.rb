class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :day

  enum category: %i[dayoff vacation shift]

  validates :category, presence: true
end
