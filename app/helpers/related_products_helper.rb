# frozen_string_literal: true

module RelatedProductsHelper
  def backend_related_resource_url(object)
    if object.instance_of? Spree::Product
      admin_product_path(object)
    elsif object.instance_of? Spree::Variant
      return edit_admin_product_path(object.product) if object.is_master?

      edit_admin_product_variant_path(object.product, object)
    end
  end

  def frontend_related_resource_url(object, _options = {})
    if object.instance_of? Spree::Product
      product_path(object)
    elsif object.instance_of? Spree::Variant
      product_path(object.product)
    end
  end
end
