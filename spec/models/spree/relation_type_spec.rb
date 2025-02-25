# frozen_string_literal: true

RSpec.describe Spree::RelationType, type: :model do
  context 'relations' do
    it { is_expected.to have_many(:relations).dependent(:destroy) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:applies_from) }
    it { is_expected.to validate_presence_of(:applies_to) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to have_readonly_attribute(:bidirectional) }

    it 'does not create duplicate names' do
      create(:product_relation_type, name: 'Gears')
      expect {
        create(:product_relation_type, name: 'gears')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    describe 'bidirectional validation' do
      context 'when applies_from and applies_to are equal' do
        subject { build(:relation_type, :from_product_to_product) }

        it { expect(subject).to allow_values(true, false, nil).for(:bidirectional) }
      end

      context 'when applies_from and applies_to are not equal' do
        subject { build(:relation_type, :from_product_to_variant) }

        it { expect(subject).to allow_values(false, nil).for(:bidirectional) }
        it { expect(subject).not_to allow_value(true).for(:bidirectional) }
      end
    end
  end
end
