# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data in development
if Rails.env.development?
  puts "Cleaning database..."
  Milestone.destroy_all
  Post.destroy_all
  User.destroy_all
  Family.destroy_all
  puts "Database cleaned!"
end

# Create families
puts "Creating families..."

families = [
  { name: "The Johnsons" },
  { name: "The Garcias" },
  { name: "The Chen Family" }
]

created_families = families.map do |family_attrs|
  Family.create!(family_attrs)
end

puts "Created #{created_families.count} families"

# Create users for each family
puts "Creating family members..."

# Family member templates with heartwarming details
family_members = {
  "The Johnsons" => [
    { first_name: "David", last_name: "Johnson", nickname: "Dad", birthdate: 35.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "davidj", password: "password123" },
    { first_name: "Sarah", last_name: "Johnson", nickname: "Mom", birthdate: 33.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "sarahj", password: "password123" },
    { first_name: "Emma", last_name: "Johnson", nickname: "Emmy", birthdate: 8.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Liam", last_name: "Johnson", nickname: "Li", birthdate: 5.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Sophie", last_name: "Johnson", nickname: "Soph", birthdate: 2.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Margaret", last_name: "Johnson", nickname: "Grandma Maggie", birthdate: 65.years.ago - rand(1..365).days, role: "manager", claimed: true, username: "maggiej", password: "password123" },
    { first_name: "Robert", last_name: "Johnson", nickname: "Grandpa Bob", birthdate: 67.years.ago - rand(1..365).days, role: "manager", claimed: true, username: "bobbyj", password: "password123" }
  ],
  "The Garcias" => [
    { first_name: "Carlos", last_name: "Garcia", nickname: "Papa", birthdate: 38.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "carlosg", password: "password123" },
    { first_name: "Maria", last_name: "Garcia", nickname: "Mama", birthdate: 36.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "mariag", password: "password123" },
    { first_name: "Diego", last_name: "Garcia", nickname: "D", birthdate: 10.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Isabella", last_name: "Garcia", nickname: "Bella", birthdate: 7.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Rosa", last_name: "Garcia", nickname: "Abuela", birthdate: 70.years.ago - rand(1..365).days, role: "manager", claimed: true, username: "rosag", password: "password123" }
  ],
  "The Chen Family" => [
    { first_name: "Michael", last_name: "Chen", nickname: "Mike", birthdate: 40.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "mikec", password: "password123" },
    { first_name: "Lisa", last_name: "Chen", nickname: "Li", birthdate: 38.years.ago - rand(1..365).days, role: "admin", claimed: true, username: "lisac", password: "password123" },
    { first_name: "Ethan", last_name: "Chen", nickname: "E", birthdate: 12.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Olivia", last_name: "Chen", nickname: "Liv", birthdate: 9.years.ago - rand(1..365).days, role: "default", claimed: false },
    { first_name: "Baby", last_name: "Chen", nickname: "Little One", birthdate: 6.months.ago - rand(1..30).days, role: "default", claimed: false }
  ]
}

created_users = []

created_families.each do |family|
  members = family_members[family.name] || []
  members.each do |member_attrs|
    user = User.create!(member_attrs.merge(family: family))
    created_users << user
  end
end

puts "Created #{created_users.count} family members"

# Create heartwarming posts
puts "Creating family memories..."

post_templates = [
  # Baby milestones
  { title: "First Steps!", body: "Our little one took their first steps today! After weeks of cruising along the furniture, they suddenly let go and walked three whole steps to Daddy. The look of surprise and joy on their face was priceless. We're so proud of our brave little explorer!" },
  { title: "First Word", body: "It finally happened! After months of babbling, we heard a clear 'mama' today. My heart melted completely. We've been waiting for this moment, and it was even more special than I imagined. Now we can't stop trying to get them to say it again!" },
  { title: "Tummy Time Champion", body: "Look at our strong baby during tummy time! They held their head up for a full minute today and even tried to reach for their favorite toy. It's amazing watching them grow stronger every day. Those little grunts of determination are the cutest thing ever." },
  
  # Toddler adventures
  { title: "Playground Adventures", body: "Spent the afternoon at the park today. The kids discovered the 'best stick ever' and spent an hour making it into a magic wand, a fishing rod, and a telescope. Their imagination never ceases to amaze me. Simple joys are truly the best." },
  { title: "Helping in the Kitchen", body: "My little sous chef helped make cookies today! More flour ended up on the floor than in the bowl, but the pride on their face when we pulled the cookies from the oven was worth every bit of mess. They insisted on saving the biggest cookie for Grandma." },
  { title: "Art Day Masterpiece", body: "Today's art project: handprint flowers for Mother's Day. What started as a simple craft turned into rainbow hands and giggles galore. The kitchen table may never be the same, but these colorful memories will last forever. Already framed and hanging on the fridge!" },
  
  # School memories
  { title: "First Day of Kindergarten", body: "Where did the time go? Our baby started kindergarten today! New backpack, nervous smile, and so much excitement. They were so brave walking into that classroom. I may have cried a little (okay, a lot) after drop-off. Here's to new adventures!" },
  { title: "School Play Success", body: "Our little star was a tree in the school play tonight, and they delivered their one line perfectly! 'I am a mighty oak!' never sounded so good. The costume we made together was a hit, even if they could barely walk in it. So proud of our performer!" },
  { title: "Reading Breakthrough", body: "They read their first book all by themselves today! 'The Cat Sat' might only be eight words long, but watching them sound out each word and beam with pride at the end was magical. We've read it together at least 20 times since. Next stop: the library!" },
  
  # Family time
  { title: "Sunday Pancake Tradition", body: "Sunday morning pancakes have become our favorite tradition. Today the kids insisted on making them into funny faces. We had pancake monsters, cats, and even an attempt at a dinosaur. The kitchen was a disaster but our bellies and hearts were full." },
  { title: "Family Movie Night", body: "Blanket fort: check. Popcorn: check. Everyone in pajamas: check. We watched the kids' favorite movie for the 100th time tonight, but seeing them quote every line and laugh at the same jokes never gets old. These cozy nights together are everything." },
  { title: "Beach Day Memories", body: "First beach trip of the summer! The kids spent hours building the 'world's biggest sandcastle' (it was about a foot tall). Seashell collecting, wave jumping, and sandy sandwiches. Exhausted, sun-kissed, and happy. Already planning our next trip!" },
  
  # Seasonal memories
  { title: "Pumpkin Patch Fun", body: "Annual pumpkin patch trip was a success! Everyone found their perfect pumpkin after much deliberation. The hayride was a hit, and we may have gone overboard with the apple cider donuts. Can't wait to carve these beauties together!" },
  { title: "Snow Day Magic", body: "Woke up to a winter wonderland! School was cancelled and we spent the day building snowmen, having snowball fights, and making snow angels. Hot chocolate with extra marshmallows was the perfect end to a perfect day. Childhood magic at its finest." },
  { title: "Spring Garden", body: "Started our family garden today! Each kid got to choose their own vegetables to plant. We have a row of 'pizza plants' (tomatoes), 'bunny food' (carrots), and 'green trees' (broccoli). Fingers crossed something actually grows! The excitement in their eyes was worth it already." },
  
  # Grandparent moments
  { title: "Grandma's Secret Recipe", body: "Spent the afternoon learning Grandma's famous chocolate chip cookie recipe. Three generations in the kitchen together, sharing stories and sneaking cookie dough. The kids were amazed that Grandma made these same cookies when I was little. Some traditions are meant to be passed down." },
  { title: "Fishing with Grandpa", body: "Grandpa took the kids fishing for the first time today. No fish were caught, but plenty of 'big ones' got away according to their stories. The patience Grandpa showed while untangling lines and baiting hooks was beautiful. They're already planning the next trip." },
  { title: "Storytime with Grandparents", body: "The best part of grandparent visits: endless storytime. Tonight Grandpa told stories about when Daddy was little, complete with old photos. The kids couldn't believe Daddy was ever their age! These connections across generations are so precious." },
  
  # Everyday magic
  { title: "Tooth Fairy Visit", body: "Lost tooth number 3! The tooth fairy letter writing has become quite elaborate. Tonight's letter included a drawing of the tooth fairy's castle and a request for fairy dust. The excitement of checking under the pillow in the morning never gets old." },
  { title: "Sick Day Cuddles", body: "Poor little one has a cold today. Silver lining: lots of cuddles, favorite books, and chicken soup. Sometimes slowing down and having a couch day together is exactly what we all need. Hoping for a speedy recovery for our snuggle bug." },
  { title: "Dance Party", body: "Rainy day dance party in the living room! We turned up the music and had a silly dance contest. Even convinced Dad to show us his 'moves.' Pretty sure the neighbors heard us laughing. These spontaneous moments of pure joy are what it's all about." },
  
  # Growth moments
  { title: "Big Kid Bed", body: "Transitioned to a big kid bed tonight! They were so excited to pick out new sheets (dinosaurs, of course). Bedtime took a little longer with all the 'I need water' and 'one more hug' requests, but seeing them so proud of being a big kid was worth it." },
  { title: "Learning to Ride", body: "Training wheels came off today! After a few wobbles and one scraped knee (kissed better), they were zooming around the driveway. The determination on their face and the triumph when they finally got it - these are the moments that make parenting so rewarding." },
  { title: "Sleepover Success", body: "First sleepover at a friend's house! They were so brave, even though I could tell they were a little nervous. Picked them up this morning full of stories about midnight snacks and ghost stories. Growing up is happening too fast!" }
]

# Create posts with variety across families
created_posts = []
post_index = 0

created_users.select { |u| u.role == "admin" || u.role == "manager" }.each do |author|
  num_posts = rand(3..7)
  
  num_posts.times do
    post_data = post_templates[post_index % post_templates.length]
    
    # Add some variety to the posts
    days_ago = rand(1..365)
    
    post = Post.create!(
      title: post_data[:title],
      body: post_data[:body],
      user: author,
      created_at: days_ago.days.ago,
      updated_at: days_ago.days.ago,
      private: rand(10) < 2 # 20% chance of being private
    )
    
    # Randomly tag family members in some posts
    if rand(10) < 6 # 60% chance of tagging
      family_members = author.family.users.where.not(id: author.id)
      tagged = family_members.sample(rand(1..[3, family_members.count].min))
      post.tagged_users = tagged
    end
    
    created_posts << post
    post_index += 1
  end
end

puts "Created #{created_posts.count} heartwarming posts"

# Create milestones
puts "Creating family milestones..."

# Create user milestones (birthdays, achievements)
created_users.each do |user|
  # Birth milestone
  if user.birthdate
    Milestone.create!(
      title: "#{user.first_name} was born!",
      description: "Welcome to the world, little one! Our family grew by one heart today.",
      milestone_date: user.birthdate,
      milestone_type: "birth",
      milestoneable: user,
      created_by_user: created_users.select(&:claimed).sample,
      is_private: false
    )
  end
  
  # Add other milestones for kids
  if user.age && user.age < 18
    # First day of school (if age appropriate)
    if user.age >= 5
      Milestone.create!(
        title: "First Day of School",
        description: "#{user.nickname || user.first_name} started kindergarten! So proud of our brave student.",
        milestone_date: (user.age - 5).years.ago + rand(0..30).days,
        milestone_type: "first_day_school",
        milestoneable: user,
        created_by_user: user.family.users.where(role: ["admin", "manager"]).sample,
        is_private: false
      )
    end
    
    # First steps (for young children)
    if user.age <= 5
      Milestone.create!(
        title: "First Steps!",
        description: "#{user.nickname || user.first_name} took their first independent steps today!",
        milestone_date: 13.months.ago + rand(0..60).days,
        milestone_type: "first_steps",
        milestoneable: user,
        created_by_user: user.family.users.where(role: ["admin", "manager"]).sample,
        is_private: false
      )
    end
  end
end

# Create family milestones
created_families.each do |family|
  # Family creation/founding
  Milestone.create!(
    title: "#{family.name} Family Established",
    description: "The beginning of our beautiful family journey together.",
    milestone_date: 15.years.ago + rand(0..365).days,
    milestone_type: "other",
    milestoneable: family,
    created_by_user: family.users.where(role: "admin").first || family.users.first,
    is_private: false
  )
  
  # Moving to new home
  if rand(10) < 7
    Milestone.create!(
      title: "Moved to Our New Home",
      description: "New house, new memories! Excited to make this house our home.",
      milestone_date: rand(1..5).years.ago,
      milestone_type: "moving",
      milestoneable: family,
      created_by_user: family.users.where(role: ["admin", "manager"]).sample,
      is_private: false
    )
  end
end

# Create post-related milestones (special memories)
created_posts.sample(10).each do |post|
  next unless rand(10) < 5 # 50% chance
  
  milestone_types = ["achievement", "other"]
  Milestone.create!(
    title: "Special Memory: #{post.title}",
    description: "A day we'll always remember!",
    milestone_date: post.created_at.to_date,
    milestone_type: milestone_types.sample,
    milestoneable: post,
    created_by_user: post.user,
    is_private: post.private
  )
end

puts "Created #{Milestone.count} milestones"

puts "\nSeed data created successfully!"
puts "Families: #{Family.count}"
puts "Users: #{User.count}"
puts "Posts: #{Post.count}"
puts "Milestones: #{Milestone.count}"

# Print login information for claimed users
puts "\nLogin credentials for claimed users:"
User.where(claimed: true).each do |user|
  puts "#{user.name} (#{user.role}): username: #{user.username}, password: password123"
end