# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ScopesHelper, type: :helper do
    describe "scopes_picker_tag" do
      let(:scope) { create(:scope) }

      it "works wrong" do
        actual = helper.scopes_picker_tag("my_scope_input", scope.id)

        expected = <<~HTML
          <div id="my_scope_input" class="data-picker picker-single" data-picker-name="my_scope_input">
            <div class="picker-values">
              <div>
                <a href="/scopes/picker?current=#{scope.id}&amp;field=my_scope_input" data-picker-value="#{scope.id}">
                  #{scope.name["en"]} (#{scope.scope_type.name["en"]})
                </a>
              </div>
            </div>
            <div class="picker-prompt">
              <a href="/scopes/picker?field=my_scope_input" role="button" aria-label="Select a scope (currently: Global scope)">Global scope</a>
            </div>
          </div>
        HTML

        expect(actual).to have_equivalent_markup_to(expected)
      end
    end

    describe "#ancestors" do
      let!(:organization) { create(:organization) }
      let!(:last_scope) { create(:scope, name: { en: "ZZZ scope" }, organization: organization) }
      let!(:first_scope) { create(:scope, name: { en: "AAA scope" }, organization: organization) }
      let!(:first_subscope) { create(:scope, name: { en: "AAA subscope" }, parent: first_scope, organization: organization) }
      let!(:last_subscope) { create(:scope, name: { en: "ZZZ subscope" }, parent: first_scope, organization: organization) }
      let!(:middle_subscope) { create(:scope, name: { en: "DDD subscope" }, parent: first_scope, organization: organization) }
      let(:expected) { [first_scope, last_scope] }
      let!(:not_in_organization) { create(:scope) }

      it "returns the scopes with no parent" do
        actual = helper.send(:ancestors, organization)

        expect(actual.count).to eq(2)
        expect(actual).to eq(expected)
        expect(actual).not_to include(not_in_organization)
      end
    end

    describe "#children_after_parent" do
      let!(:organization) { create(:organization) }
      let!(:last_scope) { create(:scope, name: { en: "ZZZ scope" }, organization: organization) }
      let!(:first_scope) { create(:scope, name: { en: "AAA scope" }, organization: organization) }
      let!(:first_subscope) { create(:scope, name: { en: "AAA subscope" }, parent: first_scope, organization: organization) }
      let!(:last_subscope) { create(:scope, name: { en: "ZZZ subscope" }, parent: first_scope, organization: organization) }
      let!(:middle_subscope) { create(:scope, name: { en: "DDD subscope" }, parent: first_scope, organization: organization) }
      let(:expected) { [[" AAA scope", first_scope.id], ["- AAA subscope", first_subscope.id], ["- DDD subscope", middle_subscope.id], ["- ZZZ subscope", last_subscope.id]] }

      it "returns the scopes with children" do
        array = []
        helper.send(:children_after_parent, first_scope, array, "")
        expect(array).to eq(expected)
      end
    end
  end
end
