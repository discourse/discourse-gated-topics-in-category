# frozen_string_literal: true

require_relative "page_objects/components/gated_topic"

RSpec.describe "Gated topics with tags" do
  fab!(:tag) { Fabricate(:tag, name: "premium") }
  fab!(:topic)
  fab!(:post) { Fabricate(:post, topic:) }

  let!(:theme) { upload_theme_component }
  let(:gated_topic) { PageObjects::Components::GatedTopic.new }

  before do
    SiteSetting.tagging_enabled = true
    theme.update_setting(:enabled_tags, "premium")
    theme.save!
  end

  it "shows gate for anonymous users when topic has gated tag" do
    topic.update!(tags: [tag])

    visit(topic.url)
    expect(gated_topic).to have_gate
  end

  it "does not show gate when topic does not have gated tag" do
    visit(topic.url)
    expect(gated_topic).to have_no_gate
  end
end
