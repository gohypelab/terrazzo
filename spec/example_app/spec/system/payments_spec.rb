require "rails_helper"

RSpec.describe "Admin Payments", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, territory: country) }
  let!(:order) { create(:order, customer: customer) }
  let!(:payment) { create(:payment, order: order) }

  describe "index" do
    it "renders the payments list" do
      visit admin_payments_path

      expect(page).to have_content(payment.id)
    end
  end

  describe "show" do
    it "renders the payment details" do
      visit admin_payment_path(payment)

      expect(page).to have_content(payment.id)
    end
  end
end
