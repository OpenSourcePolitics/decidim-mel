# frozen_string_literal: true

# This migration comes from decidim_decidim_awesome (originally 20230309124413)
class AddProposalsPrivateBody < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_proposals_proposals, :private_body, :text, null: false, default: "<xml></xml>"
  end
end
