# frozen_string_literal: true

RSpec.describe Spree::Relation, type: :model do
  context 'relations' do
    it { is_expected.to belong_to(:relation_type) }
    it { is_expected.to belong_to(:relatable) }
    it { is_expected.to belong_to(:related_to) }
    it { is_expected.to delegate_method(:bidirectional?).to(:relation_type).allow_nil }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:relation_type) }
    it { is_expected.to validate_presence_of(:relatable) }
    it { is_expected.to validate_presence_of(:related_to) }
    it { is_expected.to validate_numericality_of(:discount_amount) }

    context 'when bi-directional' do
      subject { create(:relation, :from_product_to_product, :bidirectional) }

      it { is_expected.to validate_numericality_of(:discount_amount).is_equal_to(0) }
    end
  end

  context 'callbacks' do
    let(:inverse_relation) {
      described_class.find_by(
        relation_type: subject.relation_type,
        relatable: subject.related_to,
        related_to: subject.relatable,
        description: subject.description
      )
    }

    describe 'after create' do
      context 'when relation type is not bi-directional' do
        it 'does not add an inverse relation' do
          expect { create(:product_relation) }.to change(described_class, :count).from(0).to(1)

          expect(inverse_relation).not_to be_present
        end
      end

      context 'when relation type is bi-directional' do
        subject { create(:product_relation, :bidirectional, description: 'Lorem Ipsum') }

        it 'adds an inverse relation' do
          expect { subject }.to change(described_class, :count).from(0).to(2)

          expect(inverse_relation).to be_present
        end
      end
    end

    describe 'after save' do
      subject { create(:product_relation, :bidirectional, description: old_description) }

      let(:old_description) { 'old description' }
      let(:new_description) { 'Lorem Ipsum' }

      it 'changes the inverse relation description' do
        expect(inverse_relation.description).to eq(old_description)

        subject.update(description: new_description)

        expect(inverse_relation.reload.description).to eq(new_description)
      end
    end

    describe 'after destroy' do
      subject { product_relation.destroy! }

      context 'when relation type is not bi-directional' do
        let!(:product_relation) { create(:product_relation, description: 'Lorem Ipsum') }

        it 'does not destroy the inverse relation' do
          expect { subject }.to change(described_class, :count).from(1).to(0)
        end
      end

      context 'when relation type is bi-directional' do
        let!(:product_relation) { create(:product_relation, :bidirectional, description: 'Lorem Ipsum') }

        it 'destroyes the inverse relation' do
          expect { subject }.to change(described_class, :count).from(2).to(0)

          expect(inverse_relation).not_to be_present
        end
      end
    end
  end
end
