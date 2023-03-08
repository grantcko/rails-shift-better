class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :preferences
  has_many :assignments
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :preferences
  has_one_attached :photo
  validates :name, presence: true
  include PgSearch::Model
  pg_search_scope :search_by_name,
    against: [:name],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

  def can_be_assigned?(shift)
    self.shift_errors = []
    #### if has a preference day it needs to be respected
    preferences.each do |preference|
      if preference.day == shift.day && preference.category != "time_off"
        update_error_messages(:day_preference, self, shift)
        return false
      end

      #### if someone has a shift preference it needs to be respected
      if preference.unavailable_shift_ids.include?(shift.id)
        update_error_messages(:shift_preference, self, shift)
        return false
      end
    end

    #### if someone is scheduled one night they can't be scheuduled next morning
    if Assignment.where(shift: Shift.where(day_id: shift.day.id - 1).last, user: self).count.positive? # if there are any shifts scheduled yest for this user
      yest_end = Assignment.find_by(shift: Shift.where(day_id: shift.day.id - 1).last, user: self).shift.end_time # collect yesterday's shifts end time
      today_start = shift.start_time # collect today's shift's start time
      if today_start - yest_end == 10 * 60 * 60
        update_error_messages(:late_early, self, shift)
        return false # not valid if there is 10 hours between start and end times
      end
    end

    #### can't work more than 6 days in a row
    work_days = []
    work_day_numbers = []
    assignments = Assignment.where(user: self)
    assignments.each do |assignment|
      work_days << assignment.shift.day unless work_days.include?(assignment.shift.day) # collect work days
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
            update_error_messages(:seventh_day, self, shift)
            return false
          end
        end
      end
    end

    #### needs 9 days min off in a month
    # raise
    if self.assignments.exists? && work_days.count == Day.all.count - 9 # && self.assignments.last.shift.id < shift.id
      update_error_messages(:nine_off, self, shift)
      return false
    elsif self.assignments.exists? && work_days.count > Day.all.count - 9
      update_error_messages(:less_nine_off, self, shift)
      return false
    end
    #### not work more than once on the same day
    if work_days.include?(shift.day)
      update_error_messages(:same_day, self, shift)
      return false
    end

    #### can't be scheduled on a shift that already has 3 or more people
    if shift.assignments.count >= 3
      update_error_messages(:filled, self, shift)
      return false
    end

    #### otherwise they are valid
    update_error_messages(:available, self, shift)
    return true
  end

  def update_error_messages(key, user, shift)
    all_error_messages = {
      day_preference: "day off requested",
      shift_preference: "shift_preference",
      filled: "filled. otherwise, available",
      seventh_day: "seventh_day",
      same_day: "scheduled today",
      nine_off: "max work days reached",
      less_nine_off: "max work days supassed",
      available: "available",
      late_early: "scheduled on last shift yesterday"
    }

    #  all_error_messages.delete(key)
    (user.shift_errors << shift.id) && (user.shift_errors << all_error_messages[key])
    user.save
    # raise
  end
end
