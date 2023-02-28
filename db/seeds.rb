puts "\n"
25.times {print '-'}
puts "\n\nCLEARING THE DATABASE...\n\n"

######### DESTROYING #########

Preference.destroy_all
puts "destroyed preferences"
Assignment.destroy_all
puts "destroyed assignments"
Shift.destroy_all
puts "destroyed shifts"
Day.destroy_all
puts "destroyed days"
User.destroy_all
puts "destroyed users"
puts "\n"
25.times {print '-'}

######### CREATING #########

puts "\n\nCREATING INSTANCES...\n\n"

#### USER
10.times do
  name = Faker::Name.name
  User.create!(
    name: name,
    email: name.split.first + "@gmail.com",
    password: '123123'
  )
end
puts "created #{User.count} users"

#### DAY
#### SHIFT
march_one_date = Date.new + 2460005
march_one_time = DateTime.new + 2460005
31.times do
  Day.create!(
    date: march_one_date,
  )

  times = {
    six: march_one_time + 0.25,
    nine: march_one_time + 0.375,
    twelve: march_one_time + 0.5,
    fourteen: march_one_time + 14.fdiv(24),
    seventeen: march_one_time + 17.fdiv(24),
    twenty: march_one_time + 20.fdiv(24)
  }
  march_one_time += 1
  march_one_date += 1

  Shift.create!(start_time: times[:six], end_time: times[:fourteen], day_id: Day.last.id)
  Shift.create!(start_time: times[:nine], end_time: times[:seventeen], day_id: Day.last.id)
  Shift.create!(start_time: times[:twelve], end_time: times[:twenty], day_id: Day.last.id)
end

puts "created #{Day.count} days starting on #{Day.first.date}"
puts "created #{Shift.count} shifts"

#### PREFERENCE
notes = [
  "I have a doctor's appointment across town",
  "I am meeting my brother from america",
  "I am selling my kidney to the Yakuza",
  "I am going to kill a turtle",
  "I need to take the train at this time",
]
def shift_ids(day)
  shifts = Shift.where(day: day)
  shift_ids = []
  shifts.each { |shift| shift_ids << shift.id }
end

User.all.each do |user|
  num = rand(2..3)
  3.times do
    day = Day.all.sample
    Preference.create!(
      category: 1,
      unavailable_shift_ids: shift_ids(day),
      user_id: user.id,
      day_id: day.id
    )
  end

  day = Day.all.sample
  preference = Preference.new(
    category: num,
    unavailable_shift_ids: shift_ids(day),
    user_id: user.id,
    day_id: day.id
  )

  if preference.category == "shift"
    preference.unavailable_shift_ids = [] << Shift.where(day: preference.day).sample.id
    preference.note = notes.sample
  end

  preference.save
end

puts "created #{Preference.count} preferences"

#### ASSIGNMENT
roles = %w[desk clean-up file-sorting door yelling smiling]
Shift.all.each do |shift|
  user = User.all.sample
  3.times {
    Assignment.create!(role: roles.sample, user:, shift:)
    user = User.all.sample while user == Assignment.last.user
  }
end

puts "created #{Assignment.count} assignments"
