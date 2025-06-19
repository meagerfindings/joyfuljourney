# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create families
families = []
%w[Smith Johnson Williams Brown Davis].each do |name|
  family = Family.find_or_create_by(name: "#{name} Family")
  families << family
  puts "Created family: #{family.name}"
end

# Create users
users = []
[
  { first_name: "John", last_name: "Smith", username: "johnsmith", claimed: true, role: "admin", family: families[0] },
  { first_name: "Jane", last_name: "Smith", username: "janesmith", claimed: true, role: "manager", family: families[0] },
  { first_name: "Tommy", last_name: "Smith", username: "tommysmith", claimed: false, role: "default", family: families[0] },
  { first_name: "Sarah", last_name: "Johnson", username: "sarahjohnson", claimed: true, role: "default", family: families[1] },
  { first_name: "Mike", last_name: "Johnson", username: "mikejohnson", claimed: true, role: "manager", family: families[1] },
  { first_name: "Emily", last_name: "Williams", username: "emilywilliams", claimed: true, role: "default", family: families[2] }
].each do |user_data|
  family = user_data.delete(:family)
  user = User.find_or_create_by(username: user_data[:username]) do |u|
    u.assign_attributes(user_data)
    u.password = "password123" if u.claimed?
    u.family = family
  end
  users << user
  puts "Created user: #{user.name} (#{user.username})"
end

# Create posts with notifications and activities
posts = []
[
  { title: "Tommy's First Steps!", body: "Our little Tommy took his first steps today! So excited to share this milestone with everyone. He's growing up so fast!", user: users[1], tagged_users: [users[0], users[2]] },
  { title: "Family Vacation Photos", body: "Just got back from our amazing family vacation to the beach. Here are some of our favorite moments captured!", user: users[0], tagged_users: [users[1]] },
  { title: "Sarah's Graduation Day", body: "So proud of Sarah for graduating with honors! All the hard work has paid off. Celebrating with the whole family tonight.", user: users[3], tagged_users: [users[4]] },
  { title: "Sunday Family Dinner", body: "Another wonderful Sunday dinner with the family. Grandma's recipes never disappoint! Love these moments together.", user: users[4], tagged_users: [users[3]] },
  { title: "Emily's Art Project", body: "Emily created this beautiful painting in her art class. So talented! Had to share her amazing work with everyone.", user: users[5] }
].each do |post_data|
  tagged_users = post_data.delete(:tagged_users) || []
  post = Post.find_or_create_by(title: post_data[:title]) do |p|
    p.assign_attributes(post_data)
  end
  post.tagged_users = tagged_users
  posts << post
  puts "Created post: #{post.title}"
end

# Create some milestones
milestones = []
[
  { title: "Tommy's First Words", description: "Tommy said 'mama' for the first time!", milestone_date: 6.months.ago, milestone_type: "first_words", created_by_user: users[1], milestoneable: users[2] },
  { title: "Family Moved to New House", description: "We moved into our new family home!", milestone_date: 3.months.ago, milestone_type: "life_event", created_by_user: users[0], milestoneable: families[0] },
  { title: "Sarah's High School Graduation", description: "Sarah graduated high school with honors!", milestone_date: 2.months.ago, milestone_type: "graduation", created_by_user: users[4], milestoneable: users[3] }
].each do |milestone_data|
  milestone = Milestone.find_or_create_by(title: milestone_data[:title]) do |m|
    m.assign_attributes(milestone_data)
  end
  milestones << milestone
  puts "Created milestone: #{milestone.title}"
end

# Create some reactions
reactions_data = [
  { post: posts[0], user: users[0], reaction_type: "love" },
  { post: posts[0], user: users[3], reaction_type: "like" },
  { post: posts[1], user: users[1], reaction_type: "love" },
  { post: posts[2], user: users[4], reaction_type: "celebrate" },
  { post: posts[3], user: users[3], reaction_type: "like" }
]

reactions_data.each do |reaction_data|
  reaction = Reaction.find_or_create_by(
    post: reaction_data[:post],
    user: reaction_data[:user]
  ) do |r|
    r.reaction_type = reaction_data[:reaction_type]
  end
  puts "Created reaction: #{reaction.user.name} #{reaction.reaction_type} '#{reaction.post.title}'"
end

# Create sample notifications and activities manually to demonstrate the system
puts "\n📢 Creating sample notifications and activities..."

# Simulate notifications that would be created by the service
posts.each do |post|
  # Only create notifications for posts that have family members
  next unless post.user.family

  family_members = post.user.family_members
  family_members.each do |member|
    notification = Notification.find_or_create_by(
      user: post.user,
      recipient: member,
      notifiable: post,
      notification_type: Notification::TYPES[:post_created]
    ) do |n|
      n.title = "New post from #{post.user.name}"
      n.message = "#{post.user.name} shared a new memory: \"#{post.title}\""
      n.data = {
        post_id: post.id,
        user_name: post.user.name,
        family_id: post.user.family_id
      }.to_json
    end
    puts "Created notification: #{notification.title} for #{member.name}"
  end

  # Create activity
  activity = Activity.find_or_create_by(
    user: post.user,
    trackable: post,
    activity_type: Activity::TYPES[:post_created]
  ) do |a|
    a.occurred_at = post.created_at
    a.data = {
      post_id: post.id,
      post_title: post.title,
      post_body_preview: post.body.truncate(100),
      family_id: post.user.family_id
    }.to_json
  end
  puts "Created activity: #{post.user.name} created post '#{post.title}'"
end

# Create milestone notifications and activities
milestones.each do |milestone|
  next unless milestone.created_by_user&.family

  family_members = milestone.created_by_user.family_members
  family_members.each do |member|
    notification = Notification.find_or_create_by(
      user: milestone.created_by_user,
      recipient: member,
      notifiable: milestone,
      notification_type: Notification::TYPES[:milestone_created]
    ) do |n|
      n.title = "New milestone from #{milestone.created_by_user.name}"
      n.message = "#{milestone.created_by_user.name} reached a new milestone: \"#{milestone.title}\""
      n.data = {
        milestone_id: milestone.id,
        user_name: milestone.created_by_user.name,
        family_id: milestone.created_by_user.family_id
      }.to_json
    end
    puts "Created milestone notification: #{notification.title} for #{member.name}"
  end

  # Create milestone activity
  activity = Activity.find_or_create_by(
    user: milestone.created_by_user,
    trackable: milestone,
    activity_type: Activity::TYPES[:milestone_created]
  ) do |a|
    a.occurred_at = milestone.created_at
    a.data = {
      milestone_id: milestone.id,
      milestone_title: milestone.title,
      milestone_description_preview: milestone.description&.truncate(100),
      family_id: milestone.created_by_user.family_id
    }.to_json
  end
  puts "Created milestone activity: #{milestone.created_by_user.name} created milestone '#{milestone.title}'"
end

puts "\n✅ Seeding completed!"
puts "\n📊 Summary:"
puts "👥 Families: #{Family.count}"
puts "👤 Users: #{User.count}"
puts "📝 Posts: #{Post.count}"
puts "🏆 Milestones: #{Milestone.count}"
puts "❤️ Reactions: #{Reaction.count}"
puts "🔔 Notifications: #{Notification.count}"
puts "📈 Activities: #{Activity.count}"

puts "\n🔑 Test login credentials:"
puts "Username: johnsmith, Password: password123 (Admin)"
puts "Username: janesmith, Password: password123 (Manager)"
puts "Username: sarahjohnson, Password: password123 (User)"
