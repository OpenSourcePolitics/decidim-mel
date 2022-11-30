# frozen_string_literal: true

module Decidim
  class EditorImagesController < Decidim::ApplicationController
    include FormFactory

    # overwrite original rescue_from to ensure we print messages from ajax methods (update)
    rescue_from Decidim::ActionForbidden, with: :ajax_user_has_no_permission

    def create
      enforce_permission_to :create, :editor_image

      @form = form(EditorImageForm).from_params(form_values)

      CreateEditorImage.call(@form) do
        on(:ok) do |image|
          # Customization : Add base url in image source
          url = image.attached_uploader(:file).path
          url = "#{request.base_url}#{url}" unless url&.start_with?("http")
          render json: { url: url, message: I18n.t("success", scope: "decidim.editor_images.create") }
          # EOC
        end

        on(:invalid) do |_message|
          render json: { message: I18n.t("error", scope: "decidim.editor_images.create") }, status: :unprocessable_entity
        end
      end
    end

    private

    # Rescue ajax calls and print the update.js view which prints the info on the message ajax form
    # Only if the request is AJAX, otherwise behave as Decidim standards
    def ajax_user_has_no_permission
      return user_has_no_permission unless request.xhr?

      render json: { message: I18n.t("actions.unauthorized", scope: "decidim.core") }, status: :unprocessable_entity
    end

    def form_values
      {
        file: params[:image],
        author_id: current_user.id
      }
    end

    def permission_scope
      :admin
    end
  end
end
