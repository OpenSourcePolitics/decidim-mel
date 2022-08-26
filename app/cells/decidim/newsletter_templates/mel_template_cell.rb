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
    end
  end
end
