# frozen_string_literal: true

module Spree
  module RelatedToFinder
    extend ActiveSupport::Concern

    private

    def find_related_to
      relation_type = @relation.relation_type
      return nil if relation_type.nil?

      related_to_model = relation_type.applies_to.constantize
      related_to_model.find(relation_params[:related_to_id])
    end
  end
end
