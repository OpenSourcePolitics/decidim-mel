# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EditorImagesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization, host: "test.host") }
    let(:editor_images_path) { Rails.application.routes.url_helpers.editor_images_url(organization.open_data_file.blob, only_path: true) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:admin) { create(:user, :confirmed, :admin, organization: organization) }
    let(:image) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end
    let(:invalid_image) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("invalid.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end
    let(:valid_params) { { image: image } }
    let(:invalid_params) { { image: invalid_image } }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "POST create" do
      context "when no user is signed in" do
        it "doesn't create an editor image" do
          expect do
            post :create, params: valid_params
          end.not_to(change { Decidim::EditorImage.count })

          expect(response).to have_http_status(:redirect)
        end
      end

      context "when user has no admin permissions" do
        before do
          sign_in user
        end

        it "doesn't create an editor image" do
          expect do
            post :create, params: valid_params
          end.not_to(change { Decidim::EditorImage.count })

          expect(response).to have_http_status(:redirect)
        end
      end

      context "when admin is signed in" do
        before do
          sign_in admin
        end

        it "creates an editor image" do
          expect do
            post :create, params: valid_params
          end.to change { Decidim::EditorImage.count }.by(1)

          expect(response).to have_http_status(:ok)
        end

        it "returns full image url" do
          expect do
            post :create, params: valid_params
          end.to change { Decidim::EditorImage.count }.by(1)

          active_storage_path = Decidim::EditorImage.first.attached_uploader(:file).path
          expect(response.body).to eq({ url: "http://test.host#{active_storage_path}", message: "Image uploaded successfully" }.to_json)
        end

        context "when file is not valid" do
          it "doesn't create an editor image and returns an error message" do
            expect do
              post :create, params: invalid_params
            end.not_to(change { Decidim::EditorImage.count })

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include("Error uploading image")
          end
        end

        context "when development mode" do
          before do
            allow(Rails.env).to receive(:development?).and_return(true)
          end

          it "returns full image url" do
            expect do
              post :create, params: valid_params
            end.to change { Decidim::EditorImage.count }.by(1)

            active_storage_path = Decidim::EditorImage.first.attached_uploader(:file).path
            expect(response.body).to eq({ url: "http://test.host#{active_storage_path}", message: "Image uploaded successfully" }.to_json)
          end
        end
      end
    end
  end
end
