# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusRelatedProducts
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_related_products'

    initializer 'spree.promo.register.promotion.calculators' do |app|
      if defined?(SolidusLegacyPromotions::Config)
        # Solidus 4+: legacy promotions extracted into solidus_legacy_promotions
        SolidusLegacyPromotions::Config.calculators["Spree::Promotion::Actions::CreateAdjustment"] <<
          "Spree::Calculator::RelatedProductDiscount"
      elsif Spree.solidus_gem_version < Gem::Version.new("4.0")
        # Solidus 2/3: legacy promotions still live in core
        app.config.spree.calculators.promotion_actions_create_adjustments <<
          "Spree::Calculator::RelatedProductDiscount"
      end
    end

    class << self
      def activate
        ActionView::Base.include RelatedProductsHelper
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
