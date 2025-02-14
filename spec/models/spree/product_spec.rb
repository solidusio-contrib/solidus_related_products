# frozen_string_literal: true

RSpec.describe Spree::Product, type: :model do
  context 'class' do
    describe '.relation_types' do
      it 'returns all the RelationTypes in use for this Product' do
        relation_type = create(:product_relation_type)
        expect(described_class.relation_types).to include(relation_type)
      end

      it 'does not return the RelationTypes for Variant' do
        relation_type = create(:product_relation_type, applies_from: 'Spree::Variant')
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
      @product = create(:product)
      @relation_type = create(:product_relation_type, name: 'Related Products')
    end

    describe '.related_cache_key' do
      it 'returns updated_at attribute' do
        expect(@product.related_cache_key).to eq(@product.updated_at)
      end
    end

    describe '.variant' do
      it 'returns master variant' do
        expect(@product.variant).to eq(@product.master)
      end
    end

    describe '.relations' do
      it 'has many relations' do
        relation1 = create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
        relation2 = create(:product_relation, relatable: @product, related_to: other2, relation_type: @relation_type)

        @product.reload
        expect(@product.relations).to include(relation1)
        expect(@product.relations).to include(relation2)
      end

      it 'has many relations for different RelationTypes' do
        other_relation_type = Spree::RelationType.new(name: 'Recommended Products')

        relation1 = create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
        relation2 = create(:product_relation, relatable: @product, related_to: other1,
          relation_type: other_relation_type)

        @product.reload
        expect(@product.relations).to include(relation1)
        expect(@product.relations).to include(relation2)
      end
    end

    describe 'RelationType finders' do
      context 'when the relation applies_to Spree::Product' do
        before do
          @relation = create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
          @product.reload
        end

        it 'recognizes the method with has_related_products?(method)' do
          expect(@product).to have_related_products('related_products')
        end

        it 'does not recognize non-existent methods with has_related_products?(method)' do
          expect(@product).not_to have_related_products('unrelated_products')
        end

        context 'if :no_conflict configuration is set to true' do
          around do |example|
            old_value = ::SolidusRelatedProducts.config[:no_conflict]
            ::SolidusRelatedProducts.config[:no_conflict] = true
            example.run
            ::SolidusRelatedProducts.config[:no_conflict] = old_value
          end

          it 'raises an error' do
            expect { @product.related_products }.to raise_error(NoMethodError)
          end
        end

        context 'if :no_conflict configuration is set to false' do
          around do |example|
            old_value = ::SolidusRelatedProducts.config[:no_conflict]
            ::SolidusRelatedProducts.config[:no_conflict] = false
            example.run
            ::SolidusRelatedProducts.config[:no_conflict] = old_value
          end

          it 'returns the relevant relations' do
            expect(@product.related_products).to include(other1)
          end

          it 'is the pluralised form of the RelationType name' do
            @relation_type.update(name: 'Related Product')
            expect(@product.related_products).to include(other1)
          end

          it 'does not return relations for another RelationType' do
            other_relation_type = Spree::RelationType.new(name: 'Recommended Products')

            create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
            create(:product_relation, relatable: @product, related_to: other2, relation_type: other_relation_type)

            @product.reload
            expect(@product.related_products).to include(other1)
            expect(@product.related_products).not_to include(other2)
          end

          it 'does not return Products that are deleted' do
            other1.update(deleted_at: Time.zone.now)
            expect(@product.related_products).to be_blank
          end

          it 'does not return Products that are not yet available' do
            other1.update(available_on: Time.zone.now + 1.hour)
            expect(@product.related_products).to be_blank
          end

          it 'does not return Products where available_on are blank' do
            other1.update(available_on: nil)
            expect(@product.related_products).to be_blank
          end

          it 'returns all results when .relation_filter_for_relation_type is nil' do
            expect(described_class).to receive(:relation_filter_for_relation_type).and_return(nil)
            other1.update(available_on: Time.zone.now + 1.hour)
            expect(@product.related_products).to include(other1)
          end

          context 'with an enhanced Product.relation_filter_for_products' do
            it 'restricts the filter' do
              relation_filter = described_class.relation_filter_for_products
              expect(described_class).to receive(:relation_filter_for_products).at_least(:once).and_return(relation_filter.includes(:master).where('spree_variants.cost_price > 20'))

              other1.master.update(cost_price: 10)
              other2.master.update(cost_price: 30)

              create(:product_relation, relatable: @product, related_to: other2, relation_type: @relation_type)
              results = @product.related_products
              expect(results).not_to include(other1)
              expect(results).to include(other2)
            end
          end
        end
      end

      context 'when the relation applies_to Spree::Variant' do
        let(:other1) { create(:variant) }
        let(:other2) { create(:variant) }

        before do
          @relation_type.update(applies_to: 'Spree::Variant')
          @relation = create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
          @product.reload
        end

        it 'recognizes the method with has_related_products?(method)' do
          expect(@product).to have_related_products('related_products')
        end

        it 'does not recognize non-existent methods with has_related_products?(method)' do
          expect(@product).not_to have_related_products('unrelated_products')
        end

        context 'if :no_conflict configuration is set to true' do
          around do |example|
            old_value = ::SolidusRelatedProducts.config[:no_conflict]
            ::SolidusRelatedProducts.config[:no_conflict] = true
            example.run
            ::SolidusRelatedProducts.config[:no_conflict] = old_value
          end

          it 'raises an error' do
            expect { @product.related_products }.to raise_error(NoMethodError)
          end
        end

        context 'if :no_conflict configuration is set to false' do
          around do |example|
            old_value = ::SolidusRelatedProducts.config[:no_conflict]
            ::SolidusRelatedProducts.config[:no_conflict] = false
            example.run
            ::SolidusRelatedProducts.config[:no_conflict] = old_value
          end

          it 'returns the relevant relations' do
            expect(@product.related_products).to include(other1)
          end

          it 'is the pluralised form of the RelationType name' do
            @relation_type.update(name: 'Related Product')
            expect(@product.related_products).to include(other1)
          end

          it 'does not return relations for another RelationType' do
            other_relation_type = Spree::RelationType.new(name: 'Recommended Products', applies_to: 'Spree::Variant')

            create(:product_relation, relatable: @product, related_to: other1, relation_type: @relation_type)
            create(:product_relation, relatable: @product, related_to: other2, relation_type: other_relation_type)

            @product.reload
            expect(@product.related_products).to include(other1)
            expect(@product.related_products).not_to include(other2)
          end

          it 'does not return Products that are deleted' do
            other1.product.update(deleted_at: Time.zone.now)
            expect(@product.related_products).to be_blank
          end

          it 'does not return Products that are not yet available' do
            other1.product.update(available_on: Time.zone.now + 1.hour)
            expect(@product.related_products).to be_blank
          end

          it 'does not return Products where available_on are blank' do
            other1.product.update(available_on: nil)
            expect(@product.related_products).to be_blank
          end

          it 'returns all results when .relation_filter_for_relation_type is nil' do
            expect(described_class).to receive(:relation_filter_for_relation_type).and_return(nil)
            other1.product.update(available_on: Time.zone.now + 1.hour)
            expect(@product.related_products).to include(other1)
          end

          context 'with an enhanced Product.relation_filter_for_variant' do
            it 'restricts the filter' do
              relation_filter = described_class.relation_filter_for_variants
              expect(described_class).to receive(:relation_filter_for_variants).at_least(:once).and_return(relation_filter.where('spree_variants.cost_price > 20'))

              other1.update(cost_price: 10)
              other2.update(cost_price: 30)

              create(:product_relation, relatable: @product, related_to: other2, relation_type: @relation_type)
              results = @product.related_products
              expect(results).not_to include(other1)
              expect(results).to include(other2)
            end
          end
        end
      end
    end
  end
end
