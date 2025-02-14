# frozen_string_literal: true

module SolidusRelatedProducts
  module Variant
    RSpec.describe AddRelationMethods do
      describe '#destroy_product_relations' do
        let(:klass) { Class.new(ApplicationRecord) }

        it 'adds relation removal hook with after_destroy' do
          expect(klass).to receive(:after_destroy).with(:destroy_variant_relations_to)
          klass.prepend(described_class)
        end

        context 'when after_discard is available' do
          let(:klass) do
            Class.new(ApplicationRecord) do
              def self.after_discard(*args); end
            end
          end

          it 'adds relation removal hook with after_discard' do
            expect(klass).to receive(:after_discard).with(:destroy_variant_relations_to)
            klass.prepend(described_class)
          end
        end
      end
    end
  end
end
