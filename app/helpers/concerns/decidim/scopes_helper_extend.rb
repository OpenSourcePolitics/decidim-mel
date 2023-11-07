# frozen_string_literal: true

module Decidim
  module ScopesHelperExtend
    extend ActiveSupport::Concern
    included do
      private

      def ancestors(organization = current_organization)
        @ancestors ||= Decidim::Scope.where(parent_id: nil, organization: organization).sort_by do |scope|
          translated_attribute(scope.name)
        end
      end

      def children_after_parent(ancestor, array, prefix)
        array << ["#{prefix} #{translated_attribute(ancestor.name)}", ancestor.id]
        children = ancestor.children.sort_by do |scope|
          translated_attribute(scope.name)
        end
        children.each do |child|
          children_after_parent(child, array, "#{prefix}-")
        end
      end
    end
  end
end
