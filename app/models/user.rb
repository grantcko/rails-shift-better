class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :preferences
  has_many :assignments
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

    # if someone is scheduled with night then next day can't be morning
    # raise
    # can't work more than 6 days in a row
    work_days = []
    cons_removal_day_ids = []
    work_day_numbers = []
    assignments = Assignment.where(user: self)
    assignments.each do |assignment|
      work_days << assignment.shift.day unless work_days.include?(assignment.shift.day)
      work_day_numbers << assignment.shift.day.id
      work_day_numbers.each_cons(6).each do |a, b, c, d, e, f|
        ids = [a, b, c, d, e, f]
        seventh_day_id = ids[-1] + 1
        sequence = []
        sequence << (b == a + 1)
        sequence << (c == b + 1)
        sequence << (d == c + 1)
        sequence << (e == d + 1)
        sequence << (f == e + 1)
        if sequence.exclude?(false) && sequence.count == 5 # if the user is working 6 consecutive days
          if shift.day.id == seventh_day_id && unavailable_day_ids.exclude?(shift.day.id) # user not valid if the current shift is the 7th consecutive shift and it hasn't already been removed
            work_day_numbers.delete(seventh_day_id - 1)
            unavailable_day_ids << seventh_day_id
            return false
          end
        end
      end
    end
    # not work more than once on the same day
    return false if work_days.include?(shift.day)
    # needs 9 days min off in a month
    return false if work_days.count >= Day.all.count - 9
    if Assignment.where(shift: Shift.where(day_id: shift.day.id - 1).last, user: self).count > 0 # if there are any shifts scheduled yest
      today_start = shift.start_time # collect today's shift's start time
      yest_end = Assignment.find_by(shift: Shift.where(day_id: shift.day.id - 1).last, user: self).shift.end_time # collect yesterday's shifts end time
      return false if today_start - yest_end == 10 * 60 * 60 # not valid if there is 10 hours between start and end times
    end
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
