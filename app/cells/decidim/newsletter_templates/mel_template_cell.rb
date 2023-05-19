# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class MelTemplateCell < BaseCell
      def show
        render :show
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end

      def email_footer_css
        "decidim/email"
      end

      def organization_asset_url(asset)
        "#{organization_host}#{image_pack_url(asset)}"
      end

      private

      def organization_host
        return "https://#{current_organization.host}/" unless Rails.env.development?

        "http://#{current_organization.host}:3000"
      end
    end
  end
end
