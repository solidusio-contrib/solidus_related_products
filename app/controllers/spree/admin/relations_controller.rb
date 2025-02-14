# frozen_string_literal: true

module Spree
  module Admin
    class RelationsController < BaseController
      include Spree::RelatedToFinder

      before_action :load_data, only: [:create, :destroy]
      before_action :find_relation, only: [:update, :destroy]
      respond_to :js, :html

      def create
        @relation = Relation.new(relation_params)
        @relation.relatable = @product
        @relation.related_to = find_related_to
        @relation.save

        respond_with(@relation)
      end

      def update
        return unless @relation.update(relation_params)

        flash[:success] = flash_message_for(@relation, :successfully_updated)
        redirect_to(related_admin_product_url(@relation.relatable))
      end

      def update_positions
        params[:positions].each do |id, index|
          model_class.where(id: id).update_all(position: index)
        end

        respond_to do |format|
          format.js { render plain: 'Ok' }
        end
      end

      def destroy
        if @relation.destroy
          flash[:success] = flash_message_for(@relation, :successfully_removed)

          respond_with(@relation) do |format|
            format.html { redirect_back(fallback_location: admin_product_path(@product)) }
            format.js   { render partial: "spree/admin/shared/destroy" }
          end

        else

          respond_with(@relation) do |format|
            format.html { redirect_back(fallback_location: admin_product_path(@product)) }
          end
        end
      end

      private

      def relation_params
        params.require(:relation).permit(
          :related_to, :relation_type, :relatable, :related_to_id,
          :discount_amount, :description, :relation_type_id, :position
        )
      end

      def load_data
        @product = Spree::Product.friendly.find(params[:product_id])
      end

      def find_relation
        @relation = Relation.find(params[:id])
      end

      def model_class
        Spree::Relation
      end
    end
  end
end
