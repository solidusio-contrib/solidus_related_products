# frozen_string_literal: true

module SolidusRelatedProducts
  module Variant
    module AddRelationMethods
      def self.prepended(base)
        base.extend ClassMethods

        base.has_many :relations, -> { order(:position) }, as: :relatable, dependent: :destroy

        # When a Spree::Variant is destroyed, we also want to destroy all Spree::Relations
        # "from" it as well as "to" it.
        base.after_discard :destroy_variant_relations_to if base.respond_to?(:after_discard)
        base.after_destroy :destroy_variant_relations_to
      end

      module ClassMethods
        # Returns all the Spree::RelationType's which apply_to this class.
        def relation_types
          Spree::RelationType.where(applies_from: to_s)
                             .where(applies_to: [to_s, Spree::Product.to_s])
                             .order(:name)
        end

        def relation_filter_for_products
          Spree::Product.available
        end

        def relation_filter_for_variants
          Spree::Variant.joins(:product).merge(Spree::Product.available)
        end

        def relation_filter_for_relation_type(relation_type)
          case relation_type.applies_to
          when 'Spree::Product' then relation_filter_for_products
          when 'Spree::Variant' then relation_filter_for_variants
          end
        end
      end

      # Decides if there is a relevant Spree::RelationType related to this class
      # which should be returned for this method.
      #
      # If so, it calls relations_for_relation_type. Otherwise it passes
      # it up the inheritance chain.
      def method_missing(method, *args)
        return super if ::SolidusRelatedProducts.config[:no_conflict]
        raise NoMethodError if method == :to_ary

        relation_type = find_relation_type(method)
        relation_type ? relations_for_relation_type(relation_type) : super
      end

      def respond_to_missing?(method, include_private = false)
        find_relation_type(method).present? || super
      end

      def has_related_products?(relation_method)
        find_relation_type(relation_method).present?
      end

      def destroy_variant_relations_to
        Spree::Relation.where(related_to_type: self.class.to_s, related_to_id: id).destroy_all
      end

      private

      def find_relation_type(relation_name)
        self.class.relation_types.detect { |rt| format_name(rt.name) == format_name(relation_name) }
      rescue ActiveRecord::StatementInvalid
        # This exception is throw if the relation_types table does not exist.
        # And this method is getting invoked during the execution of a migration
        # from another extension when both are used in a project.
        nil
      end

      # Returns all the Products or Variants that are related to this record for the given RelationType.
      #
      # Uses the Relations to find all the related items, and then filters
      # them using +relation_filter_for_relation_type+ to remove unwanted items.
      def relations_for_relation_type(relation_type)
        # Find all the relations that belong to us for this RelationType, ordered by position
        related_ids = relations.where(relation_type_id: relation_type.id).order(:position).pluck(:related_to_id)
        return if related_ids.empty?

        # Construct a query for all these records
        result = relation_type.applies_to.constantize.where(id: related_ids)

        # Merge in the relation_filter if it's available
        result = result.merge(relation_filter_for_relation_type(relation_type)) if relation_filter_for_relation_type(relation_type)

        # make sure results are in same order as related_ids array  (position order)
        result.where(id: related_ids).order(:position)
      end

      # Simple accessor for the class-level relation_filter_for_relation_type.
      # Could feasibly be overloaded to filter results relative to this
      # record (eg. only higher priced items)
      def relation_filter_for_relation_type(relation_type)
        self.class.relation_filter_for_relation_type(relation_type)
      end

      def format_name(name)
        name.to_s.downcase.tr(' ', '_').pluralize
      end

      Spree::Variant.prepend self
    end
  end
end
