# frozen_string_literal: true

module Spree
  class RelationType < ApplicationRecord
    has_many :relations, dependent: :destroy

    validates :name, :applies_from, :applies_to, presence: true
    validates :name, uniqueness: { case_sensitive: false }
    validate :validate_bidirectional, if: :bidirectional?

    attr_readonly :bidirectional

    private

    def validate_bidirectional
      return if applies_from == applies_to

      errors.add(:bidirectional, :bidirectional_not_allowed)
    end
  end
end
