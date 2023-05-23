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
        asset_pack_url(asset, host: organization_root_url)
      end

      private

      def organization_root_url
        @organization_root_url ||= decidim.root_url(host: organization_host)
      end

      def organization_host
        port = 3000
        @organization_host = if Rails.env.development?
                               "#{current_organization.host}:#{port}"
                             else
                               current_organization.host
                             end
      end
    end
  end
end
