require "spec_helper"

RSpec.describe Terrazzo::Field::Asset do
  let(:attachment) do
    double(
      "ActiveStorage::Attached::One",
      attached?: true,
      filename: ActiveSupport::StringInquirer.new("photo.jpg"),
      byte_size: 1_048_576,
      content_type: "image/jpeg",
      signed_id: "signed-id-abc123"
    )
  end

  let(:unattached) do
    double("ActiveStorage::Attached::One", attached?: false)
  end

  describe ".searchable?" do
    it "returns false" do
      expect(described_class.searchable?).to be false
    end
  end

  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe ".eager_load?" do
    it "returns true" do
      expect(described_class.eager_load?).to be true
    end
  end

  describe "#serialize_value" do
    context "when attached" do
      it "returns filename string for :index" do
        field = described_class.new(:photo, attachment, :index)
        expect(field.serialize_value(:index)).to eq("photo.jpg")
      end

      it "returns metadata hash for :show" do
        field = described_class.new(:photo, attachment, :show)
        result = field.serialize_value(:show)
        expect(result).to eq({
          filename: "photo.jpg",
          byteSize: 1_048_576,
          contentType: "image/jpeg"
        })
      end

      it "returns filename and signed_id for :form" do
        field = described_class.new(:photo, attachment, :form)
        result = field.serialize_value(:form)
        expect(result).to eq({
          filename: "photo.jpg",
          signedId: "signed-id-abc123"
        })
      end
    end

    context "when not attached" do
      it "returns nil for all modes" do
        %i[index show form].each do |mode|
          field = described_class.new(:photo, unattached, mode)
          expect(field.serialize_value(mode)).to be_nil
        end
      end
    end

    context "when data is nil" do
      it "returns nil" do
        field = described_class.new(:photo, nil, :index)
        expect(field.serialize_value(:index)).to be_nil
      end
    end
  end
end
