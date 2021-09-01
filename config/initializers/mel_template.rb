Decidim.content_blocks.register(:newsletter_template, :mel_template) do |content_block|
  content_block.cell = "decidim/newsletter_templates/mel_template"
  content_block.settings_form_cell = "decidim/newsletter_templates/mel_template_settings_form"
  content_block.public_name_key = "decidim.newsletter_templates.mel_template.name"

  content_block.images = [
    {
      name: :main_image,
      uploader: "Decidim::NewsletterTemplateImageUploader",
      preview: -> { ActionController::Base.helpers.asset_path("decidim/placeholder.jpg") }
    }
  ]

  content_block.settings do |settings|
    settings.attribute(
      :body,
      type: :text,
      translated: true,
      preview: -> { I18n.t("decidim.newsletter_templates.mel_template.body_preview") }
    )
  end
end
