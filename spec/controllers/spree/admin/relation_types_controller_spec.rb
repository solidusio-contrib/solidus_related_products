# frozen_string_literal: true

RSpec.describe Spree::Admin::RelationTypesController, type: :controller do
  stub_authorization!

  before { stub_authentication! }

  describe "#create" do
    subject { post :create, params: { relation_type: relation_type_params } }

    let(:relation_type_params) do
      {
        name: "Accessories",
        applies_from: "Spree::Product",
        applies_to: "Spree::Product",
        description: "Goes well with",
        bidirectional: "1",
        created_at: 1.year.ago
      }
    end

    it "creates a relation type with the permitted attributes" do
      expect { subject }.to change(Spree::RelationType, :count).by(1)
      expect(Spree::RelationType.last).to have_attributes(
        name: "Accessories",
        applies_from: "Spree::Product",
        applies_to: "Spree::Product",
        description: "Goes well with",
        bidirectional: true
      )
    end

    it "ignores attributes the form does not submit" do
      subject
      expect(Spree::RelationType.last.created_at).to be > 1.minute.ago
    end
  end

  describe "#update" do
    subject { put :update, params: { id: relation_type.id, relation_type: relation_type_params } }

    let(:relation_type) { create(:product_relation_type) }
    let(:relation_type_params) do
      {
        name: "Accessories",
        applies_from: "Spree::Variant",
        applies_to: "Spree::Variant",
        description: "Goes well with"
      }
    end

    it "updates the permitted attributes" do
      subject
      expect(relation_type.reload).to have_attributes(relation_type_params)
    end
  end
end
