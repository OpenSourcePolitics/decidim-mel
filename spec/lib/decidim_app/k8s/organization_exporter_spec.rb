# frozen_string_literal: true

require "spec_helper"
require "decidim_app/k8s/organization_exporter"

describe DecidimApp::K8s::OrganizationExporter do
  subject { described_class.new(organization, logger, export_path, image) }

  let(:organization) { create(:organization, host: organization_host, omniauth_settings: omniauth_settings) }
  let(:logger) { Logger.new($stdout) }
  let(:export_path) { Rails.root.join("tmp/test_export") }
  let(:organization_host) { "my-host.domain.org" }
<<<<<<< HEAD
  let(:organization_secondary_host) { "www.my-host.domain.org" }
=======
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
  let(:hostname) { "my-host" }
  let(:name_space) { "domain-org" }
  let(:image) { "my-image" }
  let(:omniauth_settings) do
    {
      "omniauth_settings_facebook_enabled" => true,
      "omniauth_settings_facebook_app_id" => Decidim::AttributeEncryptor.encrypt("app_id_123456"),
      "omniauth_settings_facebook_app_secret" => Decidim::AttributeEncryptor.encrypt("app_secret_123456")
    }
  end

  let(:database_name) { Rails.configuration.database_configuration[Rails.env]["database"] }

<<<<<<< HEAD
  before do
    organization.update!(secondary_hosts: [organization_secondary_host])
    allow(DecidimApp::K8s::SecondaryHostsChecker).to receive(:valid_secondary_hosts).with(host: organization_host, secondary_hosts: [organization_secondary_host])
                                                                                    .and_return([organization_secondary_host])
  end

=======
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
  describe ".export!" do
    it "calls the right methods" do
      # rubocop:disable RSpec/AnyInstance
      expect_any_instance_of(described_class).to receive(:export!)
      described_class.export!(organization, logger, export_path, image)
      # rubocop:enable RSpec/AnyInstance
    end
  end

  describe "#export!" do
    it "calls the right methods" do
      # rubocop:disable RSpec/SubjectStub
      expect(subject).to receive(:creating_directories)
      expect(subject).to receive(:exporting_env_vars)
      expect(subject).to receive(:exporting_configuration)
      # rubocop:enable RSpec/SubjectStub
      subject.export!
    end
  end

  describe "#dumping_database" do
    it "dumps the database" do
      # rubocop:disable RSpec/SubjectStub
<<<<<<< HEAD
      expect(subject).to receive(:system).with("pg_dump -Fc #{database_name} > #{export_path}/#{name_space}--#{hostname}/postgres/#{hostname}--de.dump")
=======
      expect(subject).to receive(:system).with("pg_dump -Fc #{database_name} > #{export_path}/#{name_space}--#{hostname}/postgres/#{hostname}--#{organization.host}--de.dump")
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
      # rubocop:enable RSpec/SubjectStub
      subject.dumping_database
    end
  end

  describe "#exporting_configuration" do
    before do
      FileUtils.rm_rf(export_path)
      FileUtils.mkdir_p("#{export_path}/#{name_space}--#{hostname}")
    end

    after do
      FileUtils.rm_rf(export_path)
    end

    it "exports the configuration" do
      subject.exporting_configuration
      expect(File).to exist("#{export_path}/#{name_space}--#{hostname}/application.yml")
    end
  end

  describe "#exporting_env_vars" do
    before do
      FileUtils.rm_rf(export_path)
      FileUtils.mkdir_p("#{export_path}/#{name_space}--#{hostname}/manifests")
    end

    after do
      FileUtils.rm_rf(export_path)
    end

    it "exports the env vars" do
      subject.exporting_env_vars
      expect(File).to exist("#{export_path}/#{name_space}--#{hostname}/manifests/#{hostname}-custom-env.yml")
      expect(File).to exist("#{export_path}/#{name_space}--#{hostname}/manifests/#{hostname}--de.yml")
    end
  end

  describe "#creating_directories!" do
    before do
      FileUtils.rm_rf(export_path)
    end

    after do
      FileUtils.rm_rf(export_path)
    end

    it "creates the directories" do
      subject.creating_directories
      expect(Dir.glob("#{export_path}/**/*").map(&File.method(:basename))).to match_array(["#{name_space}--#{hostname}", "postgres", "manifests"])
    end
  end

  describe "#organization_export_path" do
    it "returns the organization export path" do
      expect(subject.organization_export_path).to eq(Rails.root.join("#{export_path}/#{name_space}--#{hostname}").to_s)
    end
  end

  describe "#resource_name" do
    it "returns the resource name" do
      expect(subject.resource_name).to eq(hostname)
    end
  end

  describe "#organization_settings" do
    it "returns the correct keys" do
      expect(subject.organization_settings.keys).to eq(%w(apiVersion kind metadata spec))
    end

    it "returns the correct apiVersion" do
      expect(subject.organization_settings["apiVersion"]).to eq("apps.libre.sh/v1alpha1")
    end

    it "returns the correct kind" do
      expect(subject.organization_settings["kind"]).to eq("Decidim")
    end

    it "returns the correct metadata" do
      expect(subject.organization_settings["metadata"]).to eq({ "name" => hostname,
                                                                "namespace" => name_space })
    end

    it "returns the correct spec" do
      expect(subject.organization_settings["spec"].keys).to match_array(%w(image host additionalHosts organization locale usersRegistrationMode forceUsersToAuthenticateBeforeAccessOrganization availableAuthorizations fileUploadSettings timeZone envFrom))
    end

    it "returns the correct image" do
      expect(subject.organization_settings["spec"]["image"]).to eq(image)
    end

    it "returns the correct host and secondary hosts" do
<<<<<<< HEAD
      expect(subject.organization_settings["spec"]["host"]).to eq(organization_host)
      expect(subject.organization_settings["spec"]["additionalHosts"]).to eq([organization_secondary_host])
=======
      expect(subject.organization_settings["spec"]["host"]).to eq(organization.host)
      expect(subject.organization_settings["spec"]["additionalHosts"]).to eq(organization.secondary_hosts)
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
    end

    it "returns the correct organization" do
      expect(subject.organization_settings["spec"]["organization"].keys).to eq(["id"])
    end

    it "returns the correct time zone" do
      expect(subject.organization_settings["spec"]["timeZone"]).to eq(organization.time_zone)
    end

    it "returns the correct envFrom" do
      expect(subject.organization_settings["spec"]["envFrom"]).to eq([{ "secretRef" => { "name" => "#{hostname}-custom-env" } }])
    end
  end

  describe "#organization_columns" do
    it "returns the organization columns" do
      expect(subject.organization_columns).to eq({
                                                   "available_authorizations" => [],
                                                   "available_locales" => %w(en fr),
                                                   "default_locale" => "en",
<<<<<<< HEAD
                                                   "file_upload_settings" => {
                                                     "allowed_content_types" => {
                                                       "admin" => %w(image/* application/vnd.oasis.opendocument application/vnd.ms-* application/msword application/vnd.ms-word application/vnd.openxmlformats-officedocument application/vnd.oasis.opendocument application/pdf application/rtf text/plain),
                                                       "default" => %w(image/* application/pdf application/rtf text/plain)
                                                     },
                                                     "allowed_file_extensions" => {
                                                       "admin" => %w(jpg jpeg gif png bmp pdf doc docx xls xlsx ppt pptx ppx rtf txt odt ott odf otg ods ots),
                                                       "default" => %w(jpg jpeg gif png bmp pdf rtf txt),
                                                       "image" => %w(jpg jpeg gif png bmp ico)
                                                     },
                                                     "maximum_file_size" => {
                                                       "avatar" => 5, "default" => 10
                                                     }
                                                   },
=======
                                                   "file_upload_settings" => { "allowed_content_types" => { "admin" => %w(image/* application/vnd.oasis.opendocument application/vnd.ms-* application/msword application/vnd.ms-word application/vnd.openxmlformats-officedocument application/vnd.oasis.opendocument application/pdf application/rtf text/plain), "default" => ["image/*", "application/pdf", "application/rtf", "text/plain"] }, "allowed_file_extensions" => { "admin" => %w(jpg jpeg gif png bmp pdf doc docx xls xlsx ppt pptx ppx rtf txt odt ott odf otg ods ots), "default" => %w(jpg jpeg gif png bmp pdf rtf txt), "image" => %w(jpg jpeg gif png bmp ico) }, "maximum_file_size" => { "avatar" => 5, "default" => 10 } },
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
                                                   "force_users_to_authenticate_before_access_organization" => false,
                                                   "id" => organization.id,
                                                   "users_registration_mode" => 0
                                                 })
    end
  end

  describe "#env_vars" do
    let(:allowed_env_vars) do
      {
        "FOO" => "bar",
<<<<<<< HEAD
        "BAR" => "baz",
        "DUMMY" => 3
=======
        "BAR" => "baz"
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
      }
    end

    let(:forbidden_env_vars) do
      {
<<<<<<< HEAD
        "BACKUP_S3SYNC_BUCKET" => "bucket-1216",
        "ENABLE_RACK_ATTACK" => 1
=======
        "BACKUP_S3SYNC_BUCKET" => "bucket-1216"
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
      }
    end

    let(:returned_environment_variables) { allowed_env_vars.merge(forbidden_env_vars) }

    before do
      allow(Dotenv).to receive(:parse).with(".env").and_return(returned_environment_variables)
    end

    it "returns the env vars" do
<<<<<<< HEAD
      expect(subject.env_vars).to eq({ "FOO" => "bar", "BAR" => "baz", "DUMMY" => "3", "ENABLE_RACK_ATTACK" => "0" })
=======
      expect(subject.env_vars).to eq(allowed_env_vars)
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
    end

    context "when the .env file is empty" do
      before do
        allow(Dotenv).to receive(:parse).with(".env").and_return({})
      end

      it "returns an empty hash" do
<<<<<<< HEAD
        expect(subject.env_vars).to eq({ "ENABLE_RACK_ATTACK" => "0" })
=======
        expect(subject.env_vars).to eq({})
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
      end
    end
  end

  describe "#smtp_settings" do
    it "returns the smtp settings" do
      expect(subject.smtp_settings).to eq({ "SMTP_ADDRESS" => "smtp.example.org", "SMTP_FROM" => "test@example.org", "SMTP_PASSWORD" => "demo", "SMTP_PORT" => "25", "SMTP_USER_NAME" => "test" })
    end
<<<<<<< HEAD

    context "when smtp settings are not present" do
      before do
        organization.update!(smtp_settings: nil)
      end

      it "returns empty smtp settings" do
        expect(subject.smtp_settings).to eq({})
      end
    end
=======
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
  end

  describe "#omniauth_settings" do
    it "returns the decrypted omniauth settings" do
      expect(subject.omniauth_settings).to match("OMNIAUTH_SETTINGS_FACEBOOK_APP_ID" => "app_id_123456",
                                                 "OMNIAUTH_SETTINGS_FACEBOOK_APP_SECRET" => "app_secret_123456",
<<<<<<< HEAD
                                                 "OMNIAUTH_SETTINGS_FACEBOOK_ENABLED" => "true")
=======
                                                 "OMNIAUTH_SETTINGS_FACEBOOK_ENABLED" => true)
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
    end

    context "when the omniauth settings are not present" do
      let(:omniauth_settings) { nil }

      it "returns empty omniauth settings" do
        expect(subject.omniauth_settings).to eq({})
      end
    end

    context "when the omniauth settings are empty" do
      let(:omniauth_settings) { {} }

      it "returns empty omniauth settings" do
        expect(subject.omniauth_settings).to eq({})
      end
    end

    context "when the omniauth settings are not valid" do
      let(:omniauth_settings) do
        {
          "omniauth_settings_facebook_enabled" => true,
          "omniauth_settings_facebook_app_id" => "wrongly_encrypted_app_id_123456",
          "omniauth_settings_facebook_app_secret" => "wrongly_encrypted_app_secret_123456"
        }
      end

      it "returns the omniauth settings as it" do
        expect(subject.omniauth_settings).to match("OMNIAUTH_SETTINGS_FACEBOOK_APP_ID" => "wrongly_encrypted_app_id_123456",
                                                   "OMNIAUTH_SETTINGS_FACEBOOK_APP_SECRET" => "wrongly_encrypted_app_secret_123456",
<<<<<<< HEAD
                                                   "OMNIAUTH_SETTINGS_FACEBOOK_ENABLED" => "true")
=======
                                                   "OMNIAUTH_SETTINGS_FACEBOOK_ENABLED" => true)
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
      end
    end
  end

  describe "#all_env_vars" do
    before do
      allow(Dotenv).to receive(:parse).with(".env").and_return(returned_environment_variables)
    end

    let(:returned_environment_variables) do
      { RAILS_ENV: "production", RAILS_SERVE_STATIC_FILES: "1" }
    end

    it "returns the env vars" do
      expect(subject.all_env_vars.keys).to match_array(%w(apiVersion kind metadata stringData))
      expect(subject.all_env_vars["metadata"]["name"]).to eq("#{hostname}-custom-env")
<<<<<<< HEAD
      expect(subject.all_env_vars["stringData"].keys).to match_array(%w(ENABLE_RACK_ATTACK RAILS_ENV RAILS_SERVE_STATIC_FILES SMTP_FROM SMTP_USER_NAME SMTP_PORT SMTP_ADDRESS SMTP_PASSWORD OMNIAUTH_SETTINGS_FACEBOOK_ENABLED OMNIAUTH_SETTINGS_FACEBOOK_APP_ID OMNIAUTH_SETTINGS_FACEBOOK_APP_SECRET))
=======
      expect(subject.all_env_vars["stringData"].keys).to match_array(%w(RAILS_ENV RAILS_SERVE_STATIC_FILES SMTP_FROM SMTP_USER_NAME SMTP_PORT SMTP_ADDRESS SMTP_PASSWORD OMNIAUTH_SETTINGS_FACEBOOK_ENABLED OMNIAUTH_SETTINGS_FACEBOOK_APP_ID OMNIAUTH_SETTINGS_FACEBOOK_APP_SECRET))
>>>>>>> 28a5c60 (Create organization, system admin and admin from YAML (#339))
    end
  end
end
