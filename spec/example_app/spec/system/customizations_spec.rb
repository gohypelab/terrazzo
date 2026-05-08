require "rails_helper"

RSpec.describe "Admin Customizations", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }

  describe "ejected customers index with custom _collection" do
    let!(:customer) { create(:customer, name: "Test Customer", territory: country) }

    it "renders customers in a card grid via the ejected _collection partial" do
      visit admin_customers_path

      # Card grid layout — no table element on the customers index
      expect(page).not_to have_css("table")
      # Verify cards are rendering (uses grid layout with card divs)
      expect(page).to have_css(".grid .rounded-lg")
    end

    it "renders the custom index wrapper with a count badge" do
      visit admin_customers_path

      expect(page).to have_css('[data-testid="customer-count"]')
      expect(find('[data-testid="customer-count"]').text).to include("shown")
    end

    it "still uses the default table layout for other resources" do
      create(:order, customer: customer)
      visit admin_orders_path

      expect(page).to have_css("table")
    end
  end

  describe "ejected orders show with custom props" do
    let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
    let!(:order) { create(:order, customer: customer) }

    it "renders the custom total price prop" do
      visit admin_order_path(order)

      expect(page).to have_css('[data-testid="total-price"]')
      expect(find('[data-testid="total-price"]').text).to include("$")
    end
  end

  describe "has_many collection_attributes override" do
    let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
    let!(:order) { create(:order, customer: customer, address_city: "Springfield") }

    it "shows only the specified columns in the has_many table on customer#show" do
      visit admin_customer_path(customer)

      orders_table = find("dt", text: "Orders").find(:xpath, "../..").find("table")

      within(orders_table) do
        headers = all("th").map(&:text)
        expect(headers).to include("Id", "Address city")
        expect(headers).not_to include("Address line one", "Address line two")
        expect(page).to have_content("Springfield")
      end
    end

    it "still shows all columns on the orders index page" do
      visit admin_orders_path

      headers = all("th").map(&:text)
      expect(headers).to include("Address line one", "Address line two", "Address city")
    end
  end

  describe "has_many render_actions: false" do
    let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
    let!(:log_entry) { create(:log_entry, loggable: customer, action: "login") }

    it "hides the actions column when render_actions is false" do
      visit admin_customer_path(customer)

      log_entries_dd = find("dt", text: "Log entries").find(:xpath, "..").find("dd")

      within(log_entries_dd) do
        headers = all("th").map(&:text)
        expect(headers).not_to include("Actions")
        expect(page).to have_content("login")
      end
    end
  end

  describe "ejected email field with mail icon" do
    let!(:customer) { create(:customer, name: "Icon Test", email: "icon@example.com", territory: country) }

    it "renders a mail icon next to email on the show page" do
      visit admin_customer_path(customer)

      email_link = find("a[href='mailto:icon@example.com']")
      expect(email_link).to have_css("svg")
    end
  end

  describe "collection_item_actions customization for orders" do
    let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
    let!(:order) { create(:order, customer: customer) }

    it "shows custom action buttons on the orders index" do
      visit admin_orders_path

      expect(page).to have_link("View Order")
      expect(page).to have_link("Edit")
      expect(page).to have_link("Invoice")
      expect(page).not_to have_link("Show")
      expect(page).not_to have_link("Destroy")
    end

    it "shows custom action buttons in the has_many orders table on customer#show" do
      visit admin_customer_path(customer)

      within("table", match: :first) do
        expect(page).to have_link("View Order")
        expect(page).to have_link("Invoice")
      end
    end

    it "invoice action redirects with a flash notice" do
      visit admin_orders_path
      click_link "Invoice", match: :first

      expect(page).to have_content("Printing invoice")
    end

    it "renders Invoice link without data-sg-visit when sg_visit is false" do
      visit admin_orders_path

      invoice_link = find("a", text: "Invoice", match: :first)
      expect(invoice_link["data-sg-visit"]).to be_nil

      # Other links should still have data-sg-visit
      view_link = find("a", text: "View Order", match: :first)
      expect(view_link["data-sg-visit"]).to be_present
    end

    it "non-order resources still use default actions" do
      create(:customer, name: "Other Customer", territory: country)
      visit admin_customers_path

      # Custom card grid — no table, no action links from default helper
      expect(page).not_to have_link("View Order")
      expect(page).not_to have_link("Invoice")
    end
  end

  describe "custom layout via setLayout" do
    it "renders the custom layout on index pages" do
      visit admin_countries_path
      expect(page).to have_css('[data-testid="custom-layout"]')
    end

    it "renders the custom layout on show pages" do
      visit admin_country_path(country)
      expect(page).to have_css('[data-testid="custom-layout"]')
    end

    it "renders the custom layout on new pages" do
      visit new_admin_page_path
      expect(page).to have_css('[data-testid="custom-layout"]')
    end
  end

  describe "ejected boolean field with icons" do
    let!(:customer) { create(:customer, name: "Bool Test", hidden: false, territory: country) }

    it "renders a boolean icon on the show page" do
      visit admin_customer_path(customer)

      # The "Hidden" field row should contain an SVG icon (XCircle for false)
      hidden_row = find("dt", text: "Hidden").find(:xpath, "..").find("dd")
      expect(hidden_row).to have_css("svg")
    end
  end

  describe "number field with suffix option" do
    let!(:product) { create(:product, name: "Widget", release_year: 2024) }

    it "renders the suffix next to the number value on the show page" do
      visit admin_product_path(product)

      release_row = find("dt", text: "Release year").find(:xpath, "..").find("dd")
      expect(release_row).to have_text("2024 AD")
    end
  end

  describe "has_many pagination" do
    let!(:customer) { create(:customer, name: "Paginate Customer", territory: country) }

    before do
      12.times { create(:order, customer: customer) }
    end

    it "shows 5 rows on page 1 with correct pagination info" do
      visit admin_customer_path(customer)

      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) do
        expect(all("tbody tr").count).to eq(5)
        expect(page).to have_text("Page 1 of 3")
        expect(page).to have_text("12 total")
      end
    end

    it "shows disabled Prev and enabled Next on page 1" do
      visit admin_customer_path(customer)

      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) do
        expect(page).to have_button("Prev", disabled: true)
        expect(page).to have_link("Next")
      end
    end

    it "navigates to page 2 and updates URL" do
      visit admin_customer_path(customer)

      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) do
        click_link "Next"
      end

      expect(page).to have_current_path(/hm_orders_page=2/)
      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) do
        expect(all("tbody tr").count).to eq(5)
        expect(page).to have_text("Page 2 of 3")
      end
    end

    it "shows disabled Next on the last page" do
      visit admin_customer_path(customer, hm_orders_page: 3)

      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) do
        expect(all("tbody tr").count).to eq(2)
        expect(page).to have_text("Page 3 of 3")
        expect(page).to have_link("Prev")
        expect(page).to have_button("Next", disabled: true)
      end
    end

    it "does not show 'Show more' text" do
      visit admin_customer_path(customer)
      expect(page).not_to have_text("Show more")
    end

    it "paginates each has_many independently" do
      8.times { create(:log_entry, loggable: customer, action: "login") }

      visit admin_customer_path(customer, hm_orders_page: 2)

      # Orders on page 2
      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) { expect(page).to have_text("Page 2 of 3") }

      # Navigate log_entries to page 2
      log_entries_dd = find("dt", text: "Log entries").find(:xpath, "..").find("dd")
      within(log_entries_dd) { click_link "Next" }

      expect(page).to have_current_path(/hm_orders_page=2/)
      expect(page).to have_current_path(/hm_log_entries_page=2/)

      orders_dd = find("dt", text: "Orders").find(:xpath, "..").find("dd")
      within(orders_dd) { expect(page).to have_text("Page 2 of 3") }
    end
  end
end
