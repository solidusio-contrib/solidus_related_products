# frozen_string_literal: true

Rails.application.config.to_prepare do
  Spree::Backend::Config.configure do |config|
    config.menu_items = config.menu_items.map do |item|
      if item.label.to_sym == :products
        # The API of the MenuItem class changes in Solidus 4.2.0
        if item.respond_to?(:children)
          unless item.children.any? { |child| child.label == :relation_types }
            item.children << Spree::BackendConfiguration::MenuItem.new(
              label: :relation_types,
              condition: -> { can?(:admin, Spree::RelationType) },
              url: -> { Spree::Core::Engine.routes.url_helpers.admin_relation_types_path },
              match_path: "/relation_types"
            )
          end
        else
          item.sections << :relation_types
        end
      end
      item
    end
  end
end
