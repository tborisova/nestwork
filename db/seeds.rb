# frozen_string_literal: true

# Seeds for Nestwork - Interior Design Project Management
# Run with: bin/rails db:seed
# Reset and seed: bin/rails db:reset (runs db:drop, db:create, db:migrate, db:seed)

puts "Seeding database..."

# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  Comment.destroy_all
  SelectionOption.destroy_all
  Selection.destroy_all
  Product.destroy_all
  Room.destroy_all
  ProjectClient.destroy_all
  ProjectDesigner.destroy_all
  Project.destroy_all
  FirmClient.destroy_all
  FirmDesigner.destroy_all
  Firm.destroy_all
  User.destroy_all
end

# ===================
# USERS - Designers
# ===================
puts "Creating designers..."

designers = [
  { name: "Emma Rodriguez", email: "emma@luxeinteriors.com" },
  { name: "James Chen", email: "james@luxeinteriors.com" },
  { name: "Sofia Andersson", email: "sofia@modernspaces.co" },
  { name: "Marcus Thompson", email: "marcus@modernspaces.co" },
  { name: "Olivia Bennett", email: "olivia@cozydesigns.net" }
]

designer_users = designers.map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: "password123"
  )
end

# ===================
# USERS - Clients
# ===================
puts "Creating clients..."

clients = [
  { name: "Sarah Mitchell", email: "sarah.mitchell@email.com" },
  { name: "David Park", email: "david.park@email.com" },
  { name: "Rachel Green", email: "rachel.green@email.com" },
  { name: "Michael Scott", email: "michael.scott@email.com" },
  { name: "Lisa Wang", email: "lisa.wang@email.com" },
  { name: "Tom Anderson", email: "tom.anderson@email.com" },
  { name: "Jennifer Lopez", email: "jennifer.lopez@email.com" },
  { name: "Robert Brown", email: "robert.brown@email.com" }
]

client_users = clients.map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: "password123"
  )
end

# ===================
# FIRMS
# ===================
puts "Creating firms..."

firms_data = [
  {
    name: "Luxe Interiors",
    website_url: "https://luxeinteriors.com",
    owner: designer_users[0],
    designers: [designer_users[0], designer_users[1]],
    clients: [client_users[0], client_users[1], client_users[2], client_users[3]]
  },
  {
    name: "Modern Spaces Co",
    website_url: "https://modernspaces.co",
    owner: designer_users[2],
    designers: [designer_users[2], designer_users[3]],
    clients: [client_users[4], client_users[5]]
  },
  {
    name: "Cozy Designs",
    website_url: "https://cozydesigns.net",
    owner: designer_users[4],
    designers: [designer_users[4]],
    clients: [client_users[6], client_users[7]]
  }
]

firms = firms_data.map do |data|
  firm = Firm.create!(
    name: data[:name],
    website_url: data[:website_url],
    owner: data[:owner]
  )

  data[:designers].each do |designer|
    FirmDesigner.create!(firm: firm, designer: designer)
  end

  data[:clients].each do |client|
    FirmClient.create!(firm: firm, client: client)
  end

  firm
end

# ===================
# PROJECTS
# ===================
puts "Creating projects..."

projects_data = [
  # Luxe Interiors projects
  {
    name: "Manhattan Penthouse Renovation",
    status: "in_progress",
    firm: firms[0],
    designers: [designer_users[0], designer_users[1]],
    clients: [client_users[0], client_users[1]]
  },
  {
    name: "Brooklyn Brownstone Refresh",
    status: "new",
    firm: firms[0],
    designers: [designer_users[0]],
    clients: [client_users[2]]
  },
  {
    name: "Hamptons Beach House",
    status: "waiting_for_approval",
    firm: firms[0],
    designers: [designer_users[1]],
    clients: [client_users[3]]
  },
  {
    name: "Upper East Side Apartment",
    status: "done",
    firm: firms[0],
    designers: [designer_users[0], designer_users[1]],
    clients: [client_users[0]]
  },

  # Modern Spaces projects
  {
    name: "San Francisco Loft",
    status: "in_progress",
    firm: firms[1],
    designers: [designer_users[2], designer_users[3]],
    clients: [client_users[4]]
  },
  {
    name: "Palo Alto Family Home",
    status: "new",
    firm: firms[1],
    designers: [designer_users[2]],
    clients: [client_users[5]]
  },

  # Cozy Designs projects
  {
    name: "Portland Cottage Makeover",
    status: "in_progress",
    firm: firms[2],
    designers: [designer_users[4]],
    clients: [client_users[6]]
  },
  {
    name: "Seattle Urban Studio",
    status: "waiting_for_approval",
    firm: firms[2],
    designers: [designer_users[4]],
    clients: [client_users[7]]
  }
]

projects = projects_data.map do |data|
  project = Project.create!(
    name: data[:name],
    status: data[:status],
    firm: data[:firm]
  )

  data[:designers].each do |designer|
    ProjectDesigner.create!(project: project, designer: designer)
  end

  data[:clients].each do |client|
    ProjectClient.create!(project: project, client: client)
  end

  project
end

# ===================
# ROOMS & PRODUCTS
# ===================
puts "Creating rooms and products..."

# Helper to create products for a room
def create_products_for_room(room, products_data)
  products_data.map do |data|
    Product.create!(
      room: room,
      name: data[:name],
      price: data[:price],
      quantity: data[:quantity] || 1,
      link: data[:link],
      status: data[:status] || "pending"
    )
  end
end

# Manhattan Penthouse (in_progress) - lots of activity
manhattan = projects[0]

living_room = Room.create!(project: manhattan, name: "Living Room", status: "in_progress")
create_products_for_room(living_room, [
  { name: "Restoration Hardware Cloud Sofa", price: 8995, link: "https://rh.com/cloud-sofa", status: "approved" },
  { name: "West Elm Coffee Table - Marble", price: 1299, link: "https://westelm.com/marble-coffee-table", status: "ordered" },
  { name: "Article Sven Armchair (x2)", price: 1398, quantity: 2, link: "https://article.com/sven", status: "approved" },
  { name: "Lulu and Georgia Area Rug 9x12", price: 2450, link: "https://luluandgeorgia.com/rugs", status: "pending" },
  { name: "CB2 Floor Lamp - Brass", price: 399, link: "https://cb2.com/floor-lamp", status: "delivered" }
])

kitchen = Room.create!(project: manhattan, name: "Kitchen", status: "review")
create_products_for_room(kitchen, [
  { name: "Sub-Zero Refrigerator 48\"", price: 19500, link: "https://subzero-wolf.com/refrigerator", status: "ordered" },
  { name: "Wolf Range 48\" Dual Fuel", price: 12800, link: "https://subzero-wolf.com/range", status: "ordered" },
  { name: "Waterworks Kitchen Faucet", price: 1850, link: "https://waterworks.com/faucets", status: "approved" },
  { name: "Custom Marble Countertops", price: 15000, link: nil, status: "pending" }
])

master_bedroom = Room.create!(project: manhattan, name: "Master Bedroom", status: "new")
create_products_for_room(master_bedroom, [
  { name: "RH Cloud Platform Bed - King", price: 5995, link: "https://rh.com/cloud-bed", status: "pending" },
  { name: "Serena & Lily Bedding Set", price: 890, link: "https://serenaandlily.com/bedding", status: "pending" },
  { name: "Circa Lighting Chandelier", price: 2200, link: "https://circalighting.com", status: "pending" }
])

master_bath = Room.create!(project: manhattan, name: "Master Bathroom", status: "new")

# Add selections for master bath (pending choices)
vanity_selection = Selection.create!(room: master_bath, name: "Double Vanity", quantity: 1)
SelectionOption.create!(selection: vanity_selection, name: "Restoration Hardware Hutton", price: 4500, link: "https://rh.com/hutton-vanity")
SelectionOption.create!(selection: vanity_selection, name: "Waterworks Henry", price: 6800, link: "https://waterworks.com/henry")
SelectionOption.create!(selection: vanity_selection, name: "Custom Built-in", price: 8500, link: nil)

mirror_selection = Selection.create!(room: master_bath, name: "Bathroom Mirrors", quantity: 2)
SelectionOption.create!(selection: mirror_selection, name: "Rejuvenation Arched Mirror", price: 699, link: "https://rejuvenation.com/mirrors")
SelectionOption.create!(selection: mirror_selection, name: "CB2 Infinity Mirror", price: 449, link: "https://cb2.com/infinity")

# Brooklyn Brownstone (new) - minimal activity
brooklyn = projects[1]
Room.create!(project: brooklyn, name: "Living Room", status: "new")
Room.create!(project: brooklyn, name: "Kitchen", status: "new")

# Hamptons Beach House (waiting_for_approval) - ready for review
hamptons = projects[2]

hamptons_living = Room.create!(project: hamptons, name: "Living Room", status: "completed")
create_products_for_room(hamptons_living, [
  { name: "Serena & Lily Malibu Sofa", price: 4998, status: "approved" },
  { name: "Serena & Lily Driftwood Coffee Table", price: 1298, status: "approved" },
  { name: "Pottery Barn Jute Rug 10x14", price: 899, status: "approved" }
])

hamptons_bedroom = Room.create!(project: hamptons, name: "Primary Suite", status: "completed")
create_products_for_room(hamptons_bedroom, [
  { name: "Serena & Lily Harbour Cane Bed", price: 3298, status: "approved" },
  { name: "Boll & Branch Sheet Set", price: 378, status: "approved" }
])

# San Francisco Loft (in_progress)
sf_loft = projects[4]

sf_living = Room.create!(project: sf_loft, name: "Open Living Space", status: "in_progress")
create_products_for_room(sf_living, [
  { name: "Herman Miller Eames Lounge Chair", price: 7495, link: "https://hermanmiller.com/eames", status: "ordered" },
  { name: "Design Within Reach Sofa", price: 5200, status: "approved" },
  { name: "Knoll Saarinen Dining Table", price: 8900, status: "pending" }
])

# Selections for SF Loft
lighting_selection = Selection.create!(room: sf_living, name: "Pendant Lights over Island", quantity: 3)
SelectionOption.create!(selection: lighting_selection, name: "Tom Dixon Beat Light", price: 895, link: "https://tomdixon.net/beat")
SelectionOption.create!(selection: lighting_selection, name: "Muuto Unfold Pendant", price: 289, link: "https://muuto.com/unfold")
SelectionOption.create!(selection: lighting_selection, name: "Flos Aim Pendant", price: 1195, link: "https://flos.com/aim")

# Portland Cottage (in_progress)
portland = projects[6]

portland_living = Room.create!(project: portland, name: "Living Room", status: "in_progress")
create_products_for_room(portland_living, [
  { name: "IKEA Ektorp Sofa", price: 599, status: "delivered" },
  { name: "Target Threshold Coffee Table", price: 249, status: "delivered" },
  { name: "Ruggable Washable Rug 8x10", price: 449, link: "https://ruggable.com", status: "approved" }
])

portland_kitchen = Room.create!(project: portland, name: "Kitchen", status: "new")
create_products_for_room(portland_kitchen, [
  { name: "IKEA Kitchen Cabinets - White", price: 3500, status: "pending" },
  { name: "Butcher Block Countertops", price: 1200, status: "pending" }
])

# ===================
# COMMENTS
# ===================
puts "Creating comments..."

# Comments on Manhattan Penthouse
Comment.create!(
  commentable: living_room,
  user: client_users[0],
  comment: "Love the direction this is going! Can we see some alternative coffee table options?",
  resolved: false
)

Comment.create!(
  commentable: living_room,
  user: designer_users[0],
  comment: "Absolutely! I'll put together a few more options by end of week.",
  resolved: false
)

Comment.create!(
  commentable: living_room.products.find_by(name: "Restoration Hardware Cloud Sofa"),
  user: client_users[1],
  comment: "This sofa is perfect for our space. Approved!",
  resolved: true
)

Comment.create!(
  commentable: living_room.products.find_by(name: "Lulu and Georgia Area Rug 9x12"),
  user: client_users[0],
  comment: "Can we see this in a lighter color? The space needs more brightness.",
  resolved: false
)

Comment.create!(
  commentable: kitchen,
  user: designer_users[1],
  comment: "Appliance delivery scheduled for next Tuesday. Please confirm someone will be home.",
  resolved: false
)

Comment.create!(
  commentable: kitchen.products.find_by(name: "Custom Marble Countertops"),
  user: client_users[0],
  comment: "What's the lead time on the marble? We're hoping to have the kitchen done by December.",
  resolved: false
)

Comment.create!(
  commentable: vanity_selection,
  user: designer_users[0],
  comment: "I recommend the Waterworks Henry - it has the best quality and fits the aesthetic we're going for.",
  resolved: false
)

Comment.create!(
  commentable: vanity_selection,
  user: client_users[0],
  comment: "The price difference is significant. Can we see the RH option in person before deciding?",
  resolved: false
)

# Comments on SF Loft
Comment.create!(
  commentable: sf_living,
  user: client_users[4],
  comment: "The Eames chair is a dream come true! So excited it's ordered.",
  resolved: true
)

Comment.create!(
  commentable: lighting_selection,
  user: designer_users[2],
  comment: "The Tom Dixon lights would make a real statement. Let me know if you want to see them in our showroom.",
  resolved: false
)

# Comments on Portland Cottage
Comment.create!(
  commentable: portland_living,
  user: client_users[6],
  comment: "Budget is tight but this is looking great! Thanks for finding affordable options.",
  resolved: true
)

Comment.create!(
  commentable: portland_kitchen,
  user: designer_users[4],
  comment: "I found a local carpenter who can install the butcher block for less. Want me to get a quote?",
  resolved: false
)

# ===================
# SUMMARY
# ===================
puts ""
puts "=" * 50
puts "SEED DATA CREATED SUCCESSFULLY!"
puts "=" * 50
puts ""
puts "ACCOUNTS (all passwords: 'password123')"
puts "-" * 50
puts ""
puts "DESIGNERS:"
designer_users.each do |user|
  firm = user.firms.first
  puts "  #{user.email} - #{firm&.name || 'No firm'}"
end
puts ""
puts "CLIENTS:"
client_users.each do |user|
  puts "  #{user.email}"
end
puts ""
puts "STATISTICS:"
puts "  Firms: #{Firm.count}"
puts "  Projects: #{Project.count}"
puts "  Rooms: #{Room.count}"
puts "  Products: #{Product.count}"
puts "  Selections: #{Selection.count}"
puts "  Comments: #{Comment.count}"
puts ""
puts "TRY THESE LOGINS:"
puts "  Designer: emma@luxeinteriors.com / password123"
puts "  Client: sarah.mitchell@email.com / password123"
puts ""
