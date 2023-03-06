class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :preferences
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :preferences
  validates :name, presence: true
  include PgSearch::Model
  pg_search_scope :search_by_name,
    against: [:name],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

  def can_be_assigned?(shift)
    # if has a preference needs to be respected
    preferences.each { |preference| return false if preference.day == shift.day }
    # can't be scheduled on a shift that already has 3 or more people
    return false if shift.assignments.count >= 3

    # needs 9 days min off in a month
    # not work more than once on the same day

    # if someone is scheduled with night then next day can't be morning

    # can't work more than 6 days in a row
    work_days = []
    cons_removal_day_ids = []
    work_day_numbers = []
    assignments = Assignment.where(user: self)
    # raise if assignments.count > 0
    assignments.each do |assignment|
      work_days << assignment.shift.day unless work_days.include?(assignment.shift.day)
      work_day_numbers << assignment.shift.day.id
      work_day_numbers.each_cons(6).all? do |a, b, c, d, e, f|
        ids = [a, b, c, d, e, f]
        sequence = []
        sequence << (b == a + 1)
        sequence << (c == b + 1)
        sequence << (d == c + 1)
        sequence << (e == d + 1)
        sequence << (f == e + 1)
        unless sequence.include?(false) # unless the user is NOT working 7 consecutive days
          return false if shift.day.id == ids[-1] + 1 # user not valid if the current shift is the 7th consecutive shift
        end
      end
    end
    return false if work_days.include?(shift.day)
    return true
  end
end

private



# if work_day_numbers.each_cons(2).count >= 6 && work_day_numbers.each_cons(2).all? { |a, b| b == a + 1 }
#   work_day_numbers = []
#   return false
# end

# cons_removal_day_ids.each do |id|
#   if work_day_numbers.include?(id)
#     raise
#     return false
#   end
# end
