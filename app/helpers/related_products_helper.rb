# frozen_string_literal: true

module RelatedProductsHelper
  def backend_related_resource_url(object)
    case object
    when Spree::Product
      admin_product_path(object)
    when Spree::Variant
      edit_admin_product_variant_path(object.product, object)
    end
  end

  def frontend_related_resource_url(object, _options = {})
    case object
    when Spree::Product
      product_path(object)
    when Spree::Variant
      product_path(object.product)
    end
  end
end

