# frozen_string_literal: true

require_relative "page_objects/components/gated_topic"

RSpec.describe "Gated topics with groups" do
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category:) }
  fab!(:post) { Fabricate(:post, topic:) }
  fab!(:group) { Fabricate(:group, name: "premium") }
  fab!(:member, :user)
  fab!(:non_member, :user)

  let!(:theme) { upload_theme_component }
  let(:gated_topic) { PageObjects::Components::GatedTopic.new }

  before do
    group.add(member)
    theme.update_setting(:enabled_categories, category.id.to_s)
    theme.update_setting(:enabled_groups, group.id.to_s)
    theme.save!
  end

  it "does not show gate for user in allowed group" do
    sign_in(member)
    visit(topic.url)
    expect(gated_topic).to have_no_gate
  end

  it "shows group gate without CTA button for user not in allowed group" do
    sign_in(non_member)
    visit(topic.url)
    expect(gated_topic).to have_gate
    expect(gated_topic).to have_group_gate
    expect(gated_topic).to have_no_group_cta_button
  end

  it "shows anonymous gate (not group gate) for anonymous users" do
    visit(topic.url)
    expect(gated_topic).to have_gate
    expect(gated_topic).to have_signup_gate
  end

  context "when no groups are configured" do
    before do
      theme.update_setting(:enabled_groups, "")
      theme.save!
    end

    it "does not show gate for any logged-in user" do
      sign_in(non_member)
      visit(topic.url)
      expect(gated_topic).to have_no_gate
    end
  end

  context "with multiple groups configured" do
    fab!(:second_group) { Fabricate(:group, name: "vip") }
    fab!(:second_group_member, :user)

    before do
      second_group.add(second_group_member)
      theme.update_setting(:enabled_groups, "#{group.id}|#{second_group.id}")
      theme.save!
    end

    it "does not show gate for user in one of the allowed groups" do
      sign_in(second_group_member)
      visit(topic.url)
      expect(gated_topic).to have_no_gate
    end
  end

  context "with only groups configured (no categories or tags)" do
    before do
      theme.update_setting(:enabled_categories, "")
      theme.save!
    end

    it "shows gate on any topic for user not in group" do
      sign_in(non_member)
      visit(topic.url)
      expect(gated_topic).to have_gate
      expect(gated_topic).to have_group_gate
    end
  end

  context "with custom button link" do
    before do
      theme.update_setting(:group_custom_button_link, "https://example.com/subscribe")
      theme.save!
    end

    it "shows group gate with CTA button linking to custom URL" do
      sign_in(non_member)
      visit(topic.url)
      expect(gated_topic).to have_gate
      expect(gated_topic).to have_group_cta_button
      expect(gated_topic).to have_group_cta_href("https://example.com/subscribe")
    end
  end
end
