class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :preferences
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  def can_be_assigned?(shift)
    # if has preference needs to be respected
    if shift.day.date == self.preferences
      return false
    end
    # can't work more than 6 days in a row
    # needs 9 days minimum off
  end
end
