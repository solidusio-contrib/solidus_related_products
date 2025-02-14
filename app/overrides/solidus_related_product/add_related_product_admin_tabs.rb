# frozen_string_literal: true

module SolidusRelatedProduct
  module AddRelatedProductAdminTabs
    Deface::Override.new(
      virtual_path: 'spree/admin/shared/_product_tabs',
      name: 'add_related_products_admin_tab',
      insert_bottom: '[data-hook="admin_product_tabs"]',
      partial: 'spree/admin/products/related_products',
      original: '4baaf4bff6bb1ddf0a8f9592833bd5794a3b1943'
    )
  end
end
