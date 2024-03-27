# frozen_string_literal: true

namespace :decidim do
  namespace :repair do
    desc "Check for nicknames that doesn't respect valid format and update them, if needed force update with REPAIR_NICKNAME_FORCE=1"
    task nickname: :environment do
      logger = Logger.new($stdout)
      logger.info("Checking all nicknames...")

      udpated_user_ids = Decidim::RepairNicknameService.run

      if udpated_user_ids.blank?
        logger.info("No users updated")
      else
        logger.info("#{udpated_user_ids.count} users updated")
        logger.info("Updated users ID : #{udpated_user_ids.join(", ")}")
      end

      logger.info("Operation terminated")
    end

    desc "Check for malformed comments body and repair them if needed"
    task comments: :environment do
      logger = Logger.new($stdout)
      logger.info("Checking all comments...")

      updated_comments_ids = Decidim::RepairCommentsService.run

      if updated_comments_ids.blank?
        logger.info("No comments updated")
      else
        logger.info("#{updated_comments_ids} comments updated")
        logger.info("Updated comments ID : #{updated_comments_ids.join(",")}")
      end

      logger.info("Operation terminated")
    end

    desc "Add all missing translation for translatable resources"

    task url_in_content: :environment do
      logger = Logger.new($stdout)
      deprecated_hosts = ENV["DEPRECATED_OBJECTSTORE_S3_HOSTS"].to_s.split(",").map(&:strip)

      if deprecated_hosts.blank?
        logger.warn("DEPRECATED_OBJECTSTORE_S3_HOSTS env variable is not set")
      else
        deprecated_hosts.each do |host|
          Decidim::RepairUrlInContentService.run(host, logger)
        end
      end
    end
  end

  namespace :awesome do
    desc "Migrate private fields from old proposals to new ones"
    task private_fields: :environment do
      Rails.logger.info("Migrating private fields from old proposals to new ones")

      proposals = Decidim::Proposals::Proposal.where(
        "private_body != ? AND private_body != ?",
        "<xml></xml>", "{}"
      ).pluck(:id, :private_body)

      Rails.logger.info("Preparing to migrate #{proposals.count} proposals")
      creations = proposals.map do |proposal_id, private_body|
        creation = Decidim::DecidimAwesome::PrivateProposalField.create(
          proposal_id: proposal_id,
          private_body: private_body
        )

        [proposal_id, creation]
      end

      if creations.any? { |_, creation| creation.invalid? }
        proposal_ids = creations.select { |ary| ary.last.invalid? }.map(&:first)
        Rails.logger.error("Failed to migrate #{proposal_ids.count} proposals")
        Rails.logger.error("Failed proposals ID : #{proposal_ids.join(", ")}")
        return
      end

      Rails.logger.info("Migrated #{creations.count} proposals")
    end
  end
end
