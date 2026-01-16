# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# if ENV["AUTH_SEED_EMAIL"].present? && ENV["AUTH_SEED_PASSWORD"].present?


ApplicationRecord.connection do
  ganesha = User.new(email: 'ganesha@llama.com', name: 'Ganesha')
  ganesha.set_password!('1')
  ganesha.save!

  firm = Firm.create! name: 'Llama Studio', owner_id: ganesha.id, website_url: 'llamastudio.com'
  FirmDesigner.create! firm_id: firm.id, designer_id: ganesha.id

  sophie = User.new(email: 'sophie@llama.com', name: 'Sophie')
  sophie.set_password!('1')
  sophie.save!
  FirmDesigner.create! firm_id: firm.id, designer_id: sophie.id

  tsveti = User.new(email: 'tsveti@example.com', name: 'Tsveti')
  tsveti.set_password!('1')
  tsveti.save!

  steph = User.new(email: 'steph@example.com', name: 'Steph')
  steph.set_password!('1')
  steph.save!

  project = Project.create! name: 'London apartments', status: 'new', firm_id: firm.id
  ProjectClient.create! client_id: tsveti.id, project_id: project.id
  ProjectClient.create! client_id: steph.id, project_id: project.id
  ProjectDesigner.create! designer_id: ganesha.id, project_id: project.id
  ProjectDesigner.create! designer_id: sophie.id, project_id: project.id
end
