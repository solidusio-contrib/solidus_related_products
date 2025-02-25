# frozen_string_literal: true

RSpec.describe Spree::Admin::RelationsController, type: :controller do
  stub_authorization!

  let(:user)     { create(:user) }
  let!(:product) { create(:product) }
  let!(:other1)  { create(:product) }

  let!(:relation_type) { create(:product_relation_type) }
  let!(:relation) do
    create(
      :product_relation,
      relatable: product,
      related_to: other1,
      relation_type: relation_type,
      position: 0
    )
  end

  before { stub_authentication! }

  describe '.model_class' do
    it 'responds to model_class as Spree::Relation' do
      expect(controller.send(:model_class)).to eq Spree::Relation
    end
  end

  describe 'with JS' do
    sign_in_as_admin!

    let(:valid_params) do
      {
        format: :js,
        product_id: product.id,
        relation: {
          related_to_id: other1.id,
          relation_type_id: relation_type.id
        }
      }
    end

    let(:invalid_params) { { format: :js, product_id: product.id } }

    describe '#create' do
      it 'is not routable' do
        post :create, params: valid_params
        expect(response.status).to be(200)
      end

      it 'returns success with valid params' do
        expect {
          post :create, params: valid_params
        }.to change(Spree::Relation, :count).by(1)
      end

      it 'creates a relation with the right type' do
        post :create, params: valid_params
        expect(Spree::Relation.last.related_to).to eq(other1)
      end

      it 'raises error with invalid params' do
        expect {
          post :create, params: invalid_params
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    describe '#update' do
      it 'redirects to product/related url' do
        put :update,
          params: { product_id: product.id, id: relation.id,
                    relation: { discount_amount: 2.0, description: 'Related Description' } }
        expect(response).to redirect_to("#{spree.admin_product_path(relation.relatable)}/related")
      end
    end

    describe '#destroy' do
      it 'records successfully' do
        expect {
          delete :destroy, params: { id: relation.id, product_id: product.id, format: :js }
        }.to change(Spree::Relation, :count).by(-1)
      end
    end

    describe '#update_positions' do
      it 'returns the correct position of the related products' do
        other2    = create(:product)
        relation2 = create(
          :product_relation, relatable: product, related_to: other2, relation_type: relation_type, position: 1
        )

        expect {
          params = {
            product_id: product.id,
            id: relation.id,
            positions: { relation.id => '1', relation2.id => '0' },
            format: :js
          }
          post :update_positions, params: params
          relation.reload
        }.to change(relation, :position).from(0).to(1)
      end
    end
  end
end
