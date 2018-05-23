module SolidusRelatedProducts
  module Product
    module AddRelationInterfaceMethods
      def name_for_relation
        name
      end

      def cache_key
        updated_at
      end

      Spree::Product.prepend self
    end
  end
end
