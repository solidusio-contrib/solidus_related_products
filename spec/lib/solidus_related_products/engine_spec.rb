# frozen_string_literal: true

RSpec.describe SolidusRelatedProducts::Engine do
  describe 'promotion calculator registration' do
    if defined?(SolidusLegacyPromotions::Config)
      it 'registers RelatedProductDiscount with solidus_legacy_promotions' do
        expect(
          SolidusLegacyPromotions::Config.calculators['Spree::Promotion::Actions::CreateAdjustment']
        ).to include('Spree::Calculator::RelatedProductDiscount')
      end
    elsif Spree.solidus_gem_version < Gem::Version.new('4.0')
      it 'registers RelatedProductDiscount with core promotion calculators' do
        expect(
          Rails.application.config.spree.calculators.promotion_actions_create_adjustments
        ).to include('Spree::Calculator::RelatedProductDiscount')
      end
    end
  end
end
