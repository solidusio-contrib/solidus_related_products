# frozen_string_literal: true

RSpec.describe Spree::Api::Variants::RelationsController, type: :controller do
  stub_authorization!
  render_views

  let(:user)     { create(:user) }
  let!(:variant) { create(:variant) }
  let(:product) { variant.product }
  let!(:other1) { create(:product) }

  let!(:relation_type) { create(:product_relation_type, applies_from: 'Spree::Variant') }
  let!(:relation) do
    create(
      :product_relation,
      relatable: variant,
      related_to: other1,
      relation_type: relation_type,
      position: 0
    )
  end

  before { stub_authentication! }

  context 'model_class' do
    it 'responds to model_class as Spree::Relation' do
      expect(controller.send(:model_class)).to eq Spree::Relation
    end
  end

  describe 'with JSON' do
    sign_in_as_admin!

    let(:valid_params) do
      {
        format: :json,
        product_id: product.id,
        variant_id: variant.id,
        relation: {
          related_to_id: other1.id,
          relation_type_id: relation_type.id
        },
        token: user.spree_api_key
      }
    end

    describe '#create' do
      it 'creates the relation' do
        post :create, params: valid_params
        expect(response.status).to eq(201)
      end

      it 'responds 422 error with invalid params' do
        post :create,
          params: { product_id: product.id, variant_id: variant.id, token: user.spree_api_key, format: :json }
        expect(response.status).to eq(422)
      end
    end

    describe '#update' do
      it 'succesfully updates the relation ' do
        params = {
          format: :json,
          product_id: product.id,
          variant_id: variant.id,
          id: relation.id,
          relation: { discount_amount: 2.0, description: 'Related Description' }
        }
        expect {
          put :update, params: params
        }.to change { relation.reload.discount_amount.to_s }.from('0.0').to('2.0')
                                                            .and change {
                                                                   relation.reload.description
                                                                 }.from(nil).to('Related Description')
      end
    end

    describe '#destroy with' do
      it 'records successfully' do
        expect {
          delete :destroy,
            params: { id: relation.id, product_id: product.id, variant_id: variant.id, token: user.spree_api_key,
                      format: :json }
        }.to change(Spree::Relation, :count).by(-1)
      end
    end

    describe '#update_positions' do
      it 'returns the correct position of the related products' do
        other2    = create(:product)
        relation2 = create(
          :product_relation, relatable: variant, related_to: other2, relation_type: relation_type, position: 1
        )

        expect {
          params = {
            product_id: product.id,
            variant_id: variant.id,
            id: relation.id,
            positions: { relation.id => '1', relation2.id => '0' },
            format: :json
          }
          post :update_positions, params: params
          relation.reload
        }.to change(relation, :position).from(0).to(1)
      end
    end
  end
end
