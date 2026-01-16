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
    end
  end
end
