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
25.times { print '-' }

######### CREATING #########

puts "\n\nCREATING INSTANCES...\n\n"

#### USER
taka = User.create!(
  manager: true,
  name: "taka",
  email: "taka@gmail.com",
  password: '123123'
)
p photo_url = "https://res.cloudinary.com/dn2mnawil/image/upload/v1678073467/Shift%20better%20user%20profile%20pics/117798839_eiqm5g.jpg"
  file = URI.open(photo_url)
  taka.photo.attach(io: file, filename: 'user.png', content_type: 'image/png')

user = User.create!(
  name: "grant",
  email: "grant@gmail.com",
  password: '123123'
)
p photo_url = "https://res.cloudinary.com/dn2mnawil/image/upload/v1678073334/Shift%20better%20user%20profile%20pics/121933082_cji135.jpg"
  file = URI.open(photo_url)
  user.photo.attach(io: file, filename: 'user.png', content_type: 'image/png')

user = User.create!(
  name: "anik",
  email: "anik@gmail.com",
  password: '123123'
)
p photo_url = "https://res.cloudinary.com/dn2mnawil/image/upload/v1678073512/Shift%20better%20user%20profile%20pics/80834097_qjxoyt.jpg"
  file = URI.open(photo_url)
  user.photo.attach(io: file, filename: 'user.png', content_type: 'image/png')

user = User.create!(
    name: "tan",
    email: "tan@gmail.com",
    password: '123123'
  )
  p photo_url = "https://res.cloudinary.com/dn2mnawil/image/upload/v1678073499/Shift%20better%20user%20profile%20pics/121886405_wm7rea.jpg"
    file = URI.open(photo_url)
    user.photo.attach(io: file, filename: 'user.png', content_type: 'image/png')

# 13.times do
#   name = Faker::Name.unique.name
#   User.create!(
#     name:,
#     email: "#{name.split.first}@gmail.com",
#     password: '123123'
#   )
# end
# puts "created #{User.count} users"

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
  shifts = Shift.where(day:)
  shift_ids = []
  shifts.each { |shift| shift_ids << shift.id }
end

User.all.each do |user|
  3.times do
    day = Day.all.sample
    Preference.create!(
      category: :day_off,
      user_id: user.id,
      day_id: day.id
    )
  end

  day = Day.all.sample

  rand(1..3).times do
    Preference.new(
      category: %i[day_off paid_dayoff].sample,
      user_id: user.id,
      day_id: day.id
    )
  end

  rand(0..2).times do
    preference = Preference.new(
      category: :time_off,
      user_id: user.id,
      day_id: day.id
    )
    preference.unavailable_shift_ids = [] << Shift.where(day: preference.day).sample.id
    preference.note = notes.sample
    preference.save
  end
end

puts "created #{Preference.count} preferences"

#### ASSIGNMENT
# Shift.all.each do |shift|
#   user = User.all.sample
#   3.times {
#     Assignment.create!(user:, shift:)
#     user = User.all.sample while user == Assignment.last.user
#   }
# end

puts "created #{Assignment.count} assignments"
