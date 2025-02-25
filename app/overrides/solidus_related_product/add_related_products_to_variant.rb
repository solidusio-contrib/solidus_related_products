# frozen_string_literal: true

module SolidusRelatedProduct
  module AddRelatedProductsToVariant
    Deface::Override.new(
      virtual_path: 'spree/admin/variants/edit',
      name: 'add_related_products_to_variant',
      insert_before: "erb[loud]:contains('form_for')",
      partial: 'spree/admin/variants/related'
    )
  end
end
