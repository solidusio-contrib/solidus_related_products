# frozen_string_literal: true

module Spree
  class Relation < ApplicationRecord
    belongs_to :relation_type
    belongs_to :relatable, polymorphic: true, touch: true
    belongs_to :related_to, polymorphic: true

    validates :relation_type, :relatable, :related_to, presence: true
    validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
    validates :discount_amount, numericality: { equal_to: 0 }, if: :bidirectional?

    after_create :create_inverse, unless: :has_inverse?, if: :bidirectional?
    after_save :update_inverse, if: :bidirectional?
    after_destroy :destroy_inverses, if: -> { bidirectional? && has_inverse? }

    delegate :bidirectional?, to: :relation_type, allow_nil: true

    def has_inverse?
      inverses.exists?
    end

    def inverses
      self.class.where(inverse_conditions)
    end

    private

    def inverse_conditions
      { relation_type: relation_type, relatable: related_to, related_to: relatable }
    end

    def inverse_extra_options
      { description: description }
    end

    def create_inverse
      self.class.create!(inverse_conditions.merge(inverse_extra_options))
    end

    def update_inverse
      inverses.update_all(inverse_extra_options)
    end

    def destroy_inverses
      inverses.destroy_all
    end
  end
end
