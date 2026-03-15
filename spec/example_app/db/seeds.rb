us = Country.find_or_create_by!(code: "US", name: "United States")
uk = Country.find_or_create_by!(code: "GB", name: "United Kingdom")
ca = Country.find_or_create_by!(code: "CA", name: "Canada")

customer_data = [
  { name: "Alice Johnson", email: "alice@example.com", kind: "vip", country_code: "US" },
  { name: "Bob Smith", email: "bob@example.com", kind: "standard", country_code: "GB" },
  { name: "Charlie Brown", email: "charlie@example.com", kind: "standard", country_code: "CA" },
  { name: "Diana Prince", email: "diana@example.com", kind: "vip", country_code: "US" },
  { name: "Eve Wilson", email: "eve@example.com", kind: "standard", country_code: "US" },
  { name: "Frank Castle", email: "frank@example.com", kind: "standard", country_code: "US" },
  { name: "Grace Hopper", email: "grace@example.com", kind: "vip", country_code: "US" },
  { name: "Hank Pym", email: "hank@example.com", kind: "standard", country_code: "CA" },
  { name: "Iris West", email: "iris@example.com", kind: "standard", country_code: "GB" },
  { name: "Jack Reacher", email: "jack@example.com", kind: "vip", country_code: "US" },
  { name: "Karen Page", email: "karen@example.com", kind: "standard", country_code: "US" },
  { name: "Leo Fitz", email: "leo@example.com", kind: "standard", country_code: "GB" },
  { name: "Maya Lopez", email: "maya@example.com", kind: "vip", country_code: "CA" },
  { name: "Nate Richards", email: "nate@example.com", kind: "standard", country_code: "US" },
  { name: "Olivia Pope", email: "olivia@example.com", kind: "vip", country_code: "US" },
  { name: "Peter Parker", email: "peter@example.com", kind: "standard", country_code: "US" },
  { name: "Quinn Hughes", email: "quinn@example.com", kind: "standard", country_code: "CA" },
  { name: "Rachel Green", email: "rachel@example.com", kind: "vip", country_code: "US" },
  { name: "Sam Wilson", email: "sam@example.com", kind: "standard", country_code: "US" },
  { name: "Tara Strong", email: "tara@example.com", kind: "standard", country_code: "CA" },
  { name: "Uma Thurman", email: "uma@example.com", kind: "vip", country_code: "GB" },
  { name: "Victor Stone", email: "victor@example.com", kind: "standard", country_code: "US" },
  { name: "Wanda Maximoff", email: "wanda@example.com", kind: "vip", country_code: "US" },
  { name: "Xavier Charles", email: "xavier@example.com", kind: "vip", country_code: "GB" },
  { name: "Yara Flor", email: "yara@example.com", kind: "standard", country_code: "CA" },
  { name: "Zara Khan", email: "zara@example.com", kind: "standard", country_code: "GB" },
  { name: "Aaron Davis", email: "aaron@example.com", kind: "standard", country_code: "US" },
  { name: "Bella Swan", email: "bella@example.com", kind: "vip", country_code: "CA" },
  { name: "Clark Kent", email: "clark@example.com", kind: "vip", country_code: "US" },
  { name: "Donna Troy", email: "donna@example.com", kind: "standard", country_code: "US" },
]

customers = customer_data.map do |attrs|
  Customer.find_or_create_by!(email: attrs[:email]) { |c| c.assign_attributes(attrs) }
end

product_data = [
  { name: "Widget Pro", price: 29.99, description: "A professional widget", image_url: "https://picsum.photos/200" },
  { name: "Gadget X", price: 49.99, description: "The ultimate gadget", image_url: "https://picsum.photos/201" },
  { name: "Thingamajig", price: 9.99, description: "You need this thing", image_url: "https://picsum.photos/202" },
  { name: "Doohickey", price: 14.99, description: "A handy doohickey", image_url: "https://picsum.photos/203" },
  { name: "Sprocket Plus", price: 39.99, description: "Premium sprocket set", image_url: "https://picsum.photos/204" },
  { name: "Gizmo Alpha", price: 24.99, description: "First in the gizmo line", image_url: "https://picsum.photos/205" },
  { name: "Contraption 3000", price: 99.99, description: "The future of contraptions", image_url: "https://picsum.photos/206" },
  { name: "Whatchamacallit", price: 7.49, description: "Everybody needs one", image_url: "https://picsum.photos/207" },
  { name: "Doodad Deluxe", price: 19.99, description: "Deluxe edition doodad", image_url: "https://picsum.photos/208" },
  { name: "Apparatus V2", price: 59.99, description: "Second generation apparatus", image_url: "https://picsum.photos/209" },
  { name: "Module Core", price: 34.99, description: "Core module for builders", image_url: "https://picsum.photos/210" },
  { name: "Component Kit", price: 44.99, description: "Everything in one kit", image_url: "https://picsum.photos/211" },
  { name: "Fixture Basic", price: 12.99, description: "Basic fixture pack", image_url: "https://picsum.photos/212" },
  { name: "Mechanism Elite", price: 74.99, description: "Elite-grade mechanism", image_url: "https://picsum.photos/213" },
  { name: "Assembly Pro", price: 54.99, description: "Professional assembly set", image_url: "https://picsum.photos/214" },
]

products = product_data.map do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) { |p| p.assign_attributes(attrs) }
end

states = %w[CA NY TX FL WA OR IL PA OH MI]
cities = %w[Springfield Riverdale Smallville Gotham Metropolis Star\ City Central\ City Keystone Bludhaven Hub\ City]

customers.each_with_index do |customer, i|
  order = Order.find_or_create_by!(customer: customer, address_line_one: "#{100 + i} Main St") do |o|
    o.address_line_two = "Suite #{i + 1}"
    o.address_city = cities[i % cities.size]
    o.address_state = states[i % states.size]
    o.address_zip = "%05d" % (10000 + i * 137)
    o.shipped_at = i.even? ? (i * 3).days.ago : nil
  end

  products.sample(rand(1..4)).each do |product|
    LineItem.find_or_create_by!(order: order, product: product) do |li|
      li.unit_price = product.price
      li.quantity = rand(1..5)
    end
  end

  Payment.find_or_create_by!(order: order)
end

# Create a few extra orders for some customers
customers.first(10).each_with_index do |customer, i|
  order = Order.find_or_create_by!(customer: customer, address_line_one: "#{200 + i} Oak Ave") do |o|
    o.address_line_two = "Apt #{i + 10}"
    o.address_city = cities[(i + 3) % cities.size]
    o.address_state = states[(i + 3) % states.size]
    o.address_zip = "%05d" % (20000 + i * 211)
    o.shipped_at = i.odd? ? (i * 2).days.ago : nil
  end

  products.sample(2).each do |product|
    LineItem.find_or_create_by!(order: order, product: product) do |li|
      li.unit_price = product.price
      li.quantity = rand(1..3)
    end
  end

  Payment.find_or_create_by!(order: order)
end

Series.find_or_create_by!(name: "Season 1")
Series.find_or_create_by!(name: "Season 2")

Host.find_or_create_by!(name: "Main Host")

post = Blog::Post.find_or_create_by!(title: "Hello World") do |p|
  p.body = "Welcome to the blog."
  p.published_at = Time.current
end

tag = Blog::Tag.find_or_create_by!(name: "announcements")
post.tags << tag unless post.tags.include?(tag)

customers.each do |customer|
  LogEntry.find_or_create_by!(loggable: customer, action: "create")
end

Order.all.each do |order|
  LogEntry.find_or_create_by!(loggable: order, action: "update")
end

products.each do |product|
  Page.find_or_create_by!(product: product) do |p|
    p.title = "#{product.name} Details"
    p.body = "Learn more about #{product.name}."
  end

  ProductMetaTag.find_or_create_by!(product: product) do |mt|
    mt.meta_title = "Buy #{product.name}"
    mt.meta_description = "#{product.description} - Best price online."
  end
end

puts "Seeded #{Customer.count} customers, #{Product.count} products, #{Order.count} orders"
puts "  + #{LogEntry.count} log entries, #{Page.count} pages, #{ProductMetaTag.count} product meta tags"
