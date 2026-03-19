# frozen_string_literal: true

module PageObjects
  module Components
    class GatedTopic < PageObjects::Components::Base
      SELECTOR = ".custom-gated-topic-container"

      def has_gate?
        has_css?(SELECTOR)
      end

      def has_no_gate?
        has_no_css?(SELECTOR)
      end

      def has_signup_gate?
        has_css?("#{SELECTOR} .custom-gated-topic-content--cta__signup")
      end

      def has_group_gate?
        has_no_css?("#{SELECTOR} .custom-gated-topic-content--cta__signup")
      end

      def has_group_cta_button?
        has_css?("#{SELECTOR} .custom-gated-topic-content--cta__group .btn-primary")
      end

      def has_no_group_cta_button?
        has_no_css?("#{SELECTOR} .custom-gated-topic-content--cta__group")
      end

      def has_group_cta_href?(href)
        has_css?("#{SELECTOR} .custom-gated-topic-content--cta__group a[href='#{href}']")
      end
    end
  end
end
