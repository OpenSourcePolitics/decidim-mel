# frozen_string_literal: true

# This migration comes from decidim (originally 20180203065600)
class UpdateUpstreamModerations < ActiveRecord::Migration[5.1]
  def up
    Decidim::Moderation.all.each { |m| m.update(upstream_moderation: "authorized") }
  end

  def down; end
end
