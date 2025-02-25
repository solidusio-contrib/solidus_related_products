# frozen_string_literal: true

RSpec.describe 'Admin Variant Relation', :js do
  stub_authorization!

  let!(:variant) { create(:variant) }
  let!(:other_product)   { create(:product) }
  let!(:other_variant)   { create(:variant, is_master: false) }

  let!(:product_relation_type) {
    create(:product_relation_type, name: 'Related Products', applies_from: 'Spree::Variant')
  }
  let!(:variant_relation_type) {
    create(:variant_relation_type, name: 'Related Variants', applies_from: 'Spree::Variant')
  }

  before do
    visit spree.edit_admin_product_variant_path(variant.product, variant)
  end

  it 'create relation with product' do
    expect(page).to have_text /ADD RELATED PRODUCT/i
    expect(page).to have_text variant.name

    within('#add-line-item') do
      select2_search product_relation_type.name, from: 'Type'
      select2_search other_product.name, from: 'Name or SKU'
      fill_in 'add_description', with: 'Related Products Description'
      fill_in 'add_discount', with: '0.8'
      click_link 'Add'
    end

    within_row(1) do
      expect(page).to have_field('relation_discount_amount', with: '0.8')
      expect(column_text(2)).to eq other_product.name
      expect(column_text(3)).to eq product_relation_type.name
      expect(page).to have_field('relation_description', with: 'Related Products Description')
    end
  end

  it 'create relation with variant' do
    expect(page).to have_text /ADD RELATED PRODUCT/i
    expect(page).to have_text variant.name

    within('#add-line-item') do
      select2_search variant_relation_type.name, from: 'Type'
      select2_search other_variant.sku, from: 'Name or SKU'
      fill_in 'add_description', with: 'Related Variants Description'
      fill_in 'add_discount', with: '0.8'
      click_link 'Add'
    end

    within_row(1) do
      expect(page).to have_field('relation_discount_amount', with: '0.8')
      expect(column_text(2)).to eq other_variant.name_for_relation
      expect(column_text(3)).to eq variant_relation_type.name
      expect(page).to have_field('relation_description', with: 'Related Variants Description')
    end
  end

  context 'with relations' do
    let!(:relation) do
      create(
        :product_relation,
        relatable: variant,
        related_to: other_product,
        relation_type: product_relation_type,
        discount_amount: 0.5,
        description: 'Related Description'
      )
    end

    before do
      visit spree.edit_admin_product_variant_path(variant.product, variant)
    end

    it 'ensure content exist' do
      expect(page).to have_text /ADD RELATED PRODUCT/i
      expect(page).to have_text variant.name
      expect(page).to have_text other_product.name

      within_row(1) do
        expect(page).to have_field('relation_discount_amount', with: '0.5')
        expect(column_text(2)).to eq other_product.name
        expect(column_text(3)).to eq product_relation_type.name
        expect(page).to have_field('relation_description', with: 'Related Description')
      end
    end

    it 'update discount' do
      within_row(1) do
        fill_in 'relation_discount_amount', with: '0.9'
        find('#update_discount_amount').click
      end

      within_row(1) do
        expect(page).to have_field('relation_discount_amount', with: '0.9')
      end
    end

    it 'update description' do
      within_row(1) do
        fill_in 'relation_description', with: 'Related description updated'
        find('#update_description').click
      end

      within_row(1) do
        expect(page).to have_field('relation_description', with: 'Related description updated')
      end
    end

    context 'delete' do
      it 'can remove records' do
        expect(page).to have_text other_product.name

        accept_confirm do
          within_row(1) do
            expect(column_text(2)).to eq other_product.name
            click_icon :trash
          end
        end

        expect(page).not_to have_text other_product.name
      end
    end
  end
end
