require "spec_helper"
require "terrazzo/has_many_pagination"

RSpec.describe Terrazzo::HasManyPagination do
  describe ".extract" do
    it "returns an empty hash when no <attr>_page params are present" do
      expect(described_class.extract({ "id" => "1", "page" => "2" }, [:orders])).to eq({})
    end

    it "extracts a single <attr>_page param into a nested options hash" do
      result = described_class.extract({ "orders_page" => "3" }, [:orders])
      expect(result).to eq({ orders: { _page: 3 } })
    end

    it "extracts multiple <attr>_page params independently" do
      result = described_class.extract({
        "orders_page" => "2",
        "log_entries_page" => "5",
        "search" => "foo"
      }, [:orders, :log_entries])
      expect(result).to eq({
        orders: { _page: 2 },
        log_entries: { _page: 5 }
      })
    end

    it "coerces the page value to an integer" do
      result = described_class.extract({ "orders_page" => "7" }, [:orders])
      expect(result[:orders][:_page]).to eq(7)
    end

    it "ignores <attr>_page params for attributes not in the allowed list" do
      result = described_class.extract({ "orders_page" => "2", "other_page" => "3" }, [:orders])
      expect(result).to eq({ orders: { _page: 2 } })
    end

    it "accepts symbol keys" do
      result = described_class.extract({ orders_page: "4" }, [:orders])
      expect(result).to eq({ orders: { _page: 4 } })
    end
  end

  describe ".param_key" do
    it "builds the URL param key for a given attribute" do
      expect(described_class.param_key(:orders)).to eq("orders_page")
      expect(described_class.param_key("log_entries")).to eq("log_entries_page")
    end
  end
end
