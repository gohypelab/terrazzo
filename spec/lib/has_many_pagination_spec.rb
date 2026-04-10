require "spec_helper"
require "terrazzo/has_many_pagination"

RSpec.describe Terrazzo::HasManyPagination do
  describe ".extract" do
    it "returns an empty hash when no hm_*_page params are present" do
      expect(described_class.extract({ "id" => "1", "page" => "2" })).to eq({})
    end

    it "extracts a single hm_<attr>_page param into a nested options hash" do
      result = described_class.extract({ "hm_orders_page" => "3" })
      expect(result).to eq({ orders: { _page: 3 } })
    end

    it "extracts multiple hm_*_page params independently" do
      result = described_class.extract({
        "hm_orders_page" => "2",
        "hm_log_entries_page" => "5",
        "search" => "foo"
      })
      expect(result).to eq({
        orders: { _page: 2 },
        log_entries: { _page: 5 }
      })
    end

    it "coerces the page value to an integer" do
      result = described_class.extract({ "hm_orders_page" => "7" })
      expect(result[:orders][:_page]).to eq(7)
    end

    it "ignores keys that only have the prefix or suffix" do
      result = described_class.extract({
        "hm__page" => "2",
        "hm_orders" => "2",
        "orders_page" => "2"
      })
      expect(result).to eq({})
    end

    it "accepts symbol keys" do
      result = described_class.extract({ hm_orders_page: "4" })
      expect(result).to eq({ orders: { _page: 4 } })
    end
  end

  describe ".param_key" do
    it "builds the URL param key for a given attribute" do
      expect(described_class.param_key(:orders)).to eq("hm_orders_page")
      expect(described_class.param_key("log_entries")).to eq("hm_log_entries_page")
    end
  end
end
