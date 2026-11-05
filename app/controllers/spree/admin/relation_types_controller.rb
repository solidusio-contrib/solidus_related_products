# frozen_string_literal: true

module Spree
  module Admin
    class RelationTypesController < ResourceController
      private

      def permitted_resource_params
        params.require(:relation_type).permit(:name, :applies_from, :applies_to, :description, :bidirectional)
      end
    end
  end
end
