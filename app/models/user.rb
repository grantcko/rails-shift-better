class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :preferences
  validates :name, presence: true

  def can_be_assigned?(shift)
    # TODO
    # if has a preference needs to be respected
    # can't work more than 6 days in a row
    # needs 9 days min off in a month
    true
  end
end
