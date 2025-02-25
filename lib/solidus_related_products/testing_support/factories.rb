# frozen_string_literal: true

FactoryBot.define do
  factory :relation, class: Spree::Relation do
    trait :from_product_to_product do
      association :relatable, factory: :product
      association :related_to, factory: :product
      association :relation_type, factory: [:relation_type, :from_product_to_product]
    end

    trait :from_product_to_variant do
      association :relatable, factory: :product
      association :related_to, factory: :variant
      association :relation_type, factory: [:relation_type, :from_product_to_variant]
    end

    trait :from_variant_to_product do
      association :relatable, factory: :variant
      association :related_to, factory: :product
      association :relation_type, factory: [:relation_type, :from_variant_to_product]
    end

    trait :from_variant_to_variant do
      association :relatable, factory: :variant
      association :related_to, factory: :variant
      association :relation_type, factory: [:relation_type, :from_variant_to_variant]
    end

    trait :bidirectional do
        after(:build) do |relation|
          relation.relation_type = build(:relation_type, bidirectional: true)
        end
    end

    factory :product_relation, traits: [:from_product_to_product]
    factory :variant_relation, traits: [:from_product_to_variant]
  end

  factory :relation_type, class: Spree::RelationType do
    name { ('A'..'Z').to_a.sample(6).join }

    trait :from_product_to_product do
      applies_from { 'Spree::Product' }
      applies_to { 'Spree::Product' }
    end

    trait :from_product_to_variant do
      applies_from { 'Spree::Product' }
      applies_to { 'Spree::Variant' }
    end

    trait :from_variant_to_product do
      applies_from { 'Spree::Variant' }
      applies_to { 'Spree::Product' }
    end

    trait :from_variant_to_variant do
      applies_from { 'Spree::Variant' }
      applies_to { 'Spree::Variant' }
    end

    factory :product_relation_type, traits: [:from_product_to_product]
    factory :variant_relation_type, traits: [:from_product_to_variant]
  end
end
