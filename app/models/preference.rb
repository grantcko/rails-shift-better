class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :day

  enum category: %i[available dayoff vacation shift]

  validates :category, presence: true
end
