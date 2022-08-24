# frozen_string_literal: true

require "rake"

class GenerateSitemapJob < ApplicationJob
  unique :while_executing, on_conflict: :log

  def perform
    Rails.application.load_tasks
    Rake::Task["sitemap:create"].invoke
  end
end
