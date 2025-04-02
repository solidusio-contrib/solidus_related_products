# frozen_string_literal: true

module Spree
  class Calculator::RelatedProductDiscount < Spree::Calculator
    def self.description
      I18n.t('spree.related_product_discount')
    end

    def compute(object)
      return if object.is_a?(Array) && object.empty?

      order = object.is_a?(Array) ? object.first.order : object
      return unless eligible?(order)

      calculate_total_discount(order)
    end

    def eligible?(order)
      order.line_items.any? { |line_item| Spree::Relation.exists?(discount_query(line_item)) }
    end

    def calculate_total_discount(order)
      order.line_items.sum do |line_item|
        calculate_line_item_discount(line_item, order)
      end
    end

    def calculate_line_item_discount(line_item, order)
      relations = fetch_discount_relations(line_item)
      discount_applies_to = filter_discounted_variants(relations)

      discount_sum = 0
      order.line_items.each do |li|
        next li unless discount_applies_to.include? li.variant

        discount = find_discount_for_variant(relations, li.variant)
        discount_sum += calculate_discount_for_quantity(discount, li, line_item)
      end

      discount_sum
    end

    def fetch_discount_relations(line_item)
      Spree::Relation.where(*discount_query(line_item))
    end

    def filter_discounted_variants(relations)
      relations.map { |rel| rel.related_to.variant }
    end

    def find_discount_for_variant(relations, variant)
      relations.detect { |rel| rel.related_to.variant == variant }.discount_amount
    end

    def calculate_discount_for_quantity(discount, line_item, reference_line_item)
      if line_item.quantity < reference_line_item.quantity
        discount * line_item.quantity
      else
        discount * reference_line_item.quantity
      end
    end

    def discount_query(line_item)
      [
        'discount_amount <> 0.0 AND ((relatable_type = ? AND relatable_id = ?) OR (relatable_type = ? AND relatable_id = ?))',
        'Spree::Product',
        line_item.variant.product.id,
        'Spree::Variant',
        line_item.variant.id
      ]
    end
  end
end
