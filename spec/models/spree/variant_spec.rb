# frozen_string_literal: true

RSpec.describe Spree::Variant, type: :model do
  context 'class' do
    describe '.relation_types' do
      it 'returns all the RelationTypes in use for this Variant' do
        relation_type = create(:product_relation_type, applies_from: 'Spree::Variant')
        expect(described_class.relation_types).to include(relation_type)
      end

      it 'does not return the RelationTypes for Product' do
        relation_type = create(:product_relation_type)
        expect(described_class.relation_types).not_to include(relation_type)
      end
    end
  end

  context 'relations' do
    it { is_expected.to have_many(:relations) }
  end

  context 'instance' do
    let(:other1) { create(:product) }
    let(:other2) { create(:product) }

    before do
      @variant = create(:variant)
      @relation_type = create(:product_relation_type, name: 'Related Products', applies_from: 'Spree::Variant')
    end

    describe '.related_cache_key' do
      it 'returns product updated_at attribute' do
        expect(@variant.related_cache_key).to eq(@variant.product.updated_at)
      end
    end

    describe '.variant' do
      it 'returns self' do
        expect(@variant.variant).to eq(@variant)
      end
    end

    describe '.relations' do
      it 'has many relations' do
        relation1 = create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
        relation2 = create(:product_relation, relatable: @variant, related_to: other2, relation_type: @relation_type)

        @variant.reload
        expect(@variant.relations).to include(relation1)
        expect(@variant.relations).to include(relation2)
      end

      it 'has many relations for different RelationTypes' do
        other_relation_type = Spree::RelationType.new(name: 'Recommended Products', applies_from: 'Spree::Variant')

        relation1 = create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
        relation2 = create(:product_relation, relatable: @variant, related_to: other1,
          relation_type: other_relation_type)

        @variant.reload
        expect(@variant.relations).to include(relation1)
        expect(@variant.relations).to include(relation2)
      end
    end

    describe 'RelationType finders' do
      context 'when the relation applies_to Spree::Product' do
        before do
          @relation = create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
          @variant.reload
        end

        it 'returns the relevant relations' do
          expect(@variant.related_products).to include(other1)
        end

        it 'recognizes the method with has_related_products?(method)' do
          expect(@variant).to have_related_products('related_products')
        end

        it 'does not recognize non-existent methods with has_related_products?(method)' do
          expect(@variant).not_to have_related_products('unrelated_products')
        end

        it 'is the pluralised form of the RelationType name' do
          @relation_type.update(name: 'Related Product')
          expect(@variant.related_products).to include(other1)
        end

        it 'does not return relations for another RelationType' do
          other_relation_type = Spree::RelationType.new(name: 'Recommended Products')

          create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
          create(:product_relation, relatable: @variant, related_to: other2, relation_type: other_relation_type)

          @variant.reload
          expect(@variant.related_products).to include(other1)
          expect(@variant.related_products).not_to include(other2)
        end

        it 'does not return Products that are deleted' do
          other1.update(deleted_at: Time.zone.now)
          expect(@variant.related_products).to be_blank
        end

        it 'does not return Products that are not yet available' do
          other1.update(available_on: Time.zone.now + 1.hour)
          expect(@variant.related_products).to be_blank
        end

        it 'does not return Products where available_on are blank' do
          other1.update(available_on: nil)
          expect(@variant.related_products).to be_blank
        end

        it 'returns all results when .relation_filter_for_relation_type is nil' do
          expect(described_class).to receive(:relation_filter_for_relation_type).and_return(nil)
          other1.update(available_on: Time.zone.now + 1.hour)
          expect(@variant.related_products).to include(other1)
        end

        context 'with an enhanced Variant.relation_filter_for_product' do
          it 'restricts the filter' do
            relation_filter = described_class.relation_filter_for_products
            expect(described_class).to receive(:relation_filter_for_products).at_least(:once).and_return(relation_filter.includes(:master).where('spree_variants.cost_price > 20'))

            other1.master.update(cost_price: 10)
            other2.master.update(cost_price: 30)

            create(:product_relation, relatable: @variant, related_to: other2, relation_type: @relation_type)
            results = @variant.related_products
            expect(results).not_to include(other1)
            expect(results).to include(other2)
          end
        end
      end

      context 'when the relation applies_to Spree::Variant' do
        let(:other1) { create(:variant) }
        let(:other2) { create(:variant) }

        before do
          @relation_type.update(applies_to: 'Spree::Variant')
          @relation = create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
          @variant.reload
        end

        it 'returns the relevant relations' do
          expect(@variant.related_products).to include(other1)
        end

        it 'recognizes the method with has_related_products?(method)' do
          expect(@variant).to have_related_products('related_products')
        end

        it 'does not recognize non-existent methods with has_related_products?(method)' do
          expect(@variant).not_to have_related_products('unrelated_products')
        end

        it 'is the pluralised form of the RelationType name' do
          @relation_type.update(name: 'Related Product')
          expect(@variant.related_products).to include(other1)
        end

        it 'does not return relations for another RelationType' do
          other_relation_type = Spree::RelationType.new(name: 'Recommended Products', applies_to: 'Spree::Variant')

          create(:product_relation, relatable: @variant, related_to: other1, relation_type: @relation_type)
          create(:product_relation, relatable: @variant, related_to: other2, relation_type: other_relation_type)

          @variant.reload
          expect(@variant.related_products).to include(other1)
          expect(@variant.related_products).not_to include(other2)
        end

        it 'does not return Products that are deleted' do
          other1.product.update(deleted_at: Time.zone.now)
          expect(@variant.related_products).to be_blank
        end

        it 'does not return Products that are not yet available' do
          other1.product.update(available_on: Time.zone.now + 1.hour)
          expect(@variant.related_products).to be_blank
        end

        it 'does not return Products where available_on are blank' do
          other1.product.update(available_on: nil)
          expect(@variant.related_products).to be_blank
        end

        it 'returns all results when .relation_filter_for_relation_type is nil' do
          expect(described_class).to receive(:relation_filter_for_relation_type).and_return(nil)
          other1.product.update(available_on: Time.zone.now + 1.hour)
          expect(@variant.related_products).to include(other1)
        end

        context 'with an enhanced Variant.relation_filter_for_variant' do
          it 'restricts the filter' do
            relation_filter = described_class.relation_filter_for_variants
            expect(described_class).to receive(:relation_filter_for_variants).at_least(:once).and_return(relation_filter.where('spree_variants.cost_price > 20'))

            other1.update(cost_price: 10)
            other2.update(cost_price: 30)

            create(:product_relation, relatable: @variant, related_to: other2, relation_type: @relation_type)
            results = @variant.related_products
            expect(results).not_to include(other1)
            expect(results).to include(other2)
          end
        end
      end
    end
  end
end
