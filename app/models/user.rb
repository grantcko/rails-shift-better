class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :preferences
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :preferences
  validates :name, presence: true

  def can_be_assigned?(shift)
    # if shift.day == self.preferences
    #   return false
    # end
    ## if has a preference needs to be respected
    preferences.each do |preference|
      return false if preference.day == shift.day
    end
    return false if shift.assignments.count > 2

    ## can't work more than 6 days in a row
    ## needs 9 days min off in a month
    true
  end
end
