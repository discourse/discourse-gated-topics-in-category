/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";

@tagName("")
export default class TopicInGatedCategory extends Component {
  hidden = true;
  enabledCategories = settings.enabled_categories
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => id);
  enabledTags = settings.enabled_tags.split("|").filter(Boolean);
  enabledGroups = settings.enabled_groups
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => !isNaN(id));

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.recalculate();
  }

  didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    this.recalculate();
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    document.body.classList.remove("topic-in-gated-category");
  }

  recalculate() {
    // TODO(https://github.com/discourse/discourse/pull/36678): The string check can be
    // removed using .discourse-compatibility once the PR is merged.

    // user is in an enabled group — always bypass
    if (
      this.currentUser?.groups?.some((g) => this.enabledGroups.includes(g.id))
    ) {
      return;
    }

    const hasGroupGating = this.enabledGroups.length > 0;
    const gatedByCategory = this.enabledCategories.includes(this.categoryId);
    const gatedByTag = this.tags?.some((t) => {
      const name = typeof t === "string" ? t : t.name;
      return this.enabledTags.includes(name);
    });
    const hasAnyCategoryOrTag =
      this.enabledCategories.length > 0 || this.enabledTags.length > 0;

    if (!hasAnyCategoryOrTag && !hasGroupGating) {
      return;
    }

    // when categories/tags are configured, topic must match one
    if (hasAnyCategoryOrTag && !gatedByCategory && !gatedByTag) {
      return;
    }

    // no groups configured — original behavior: any logged-in user bypasses
    if (!hasGroupGating && this.currentUser) {
      return;
    }

    document.body.classList.add("topic-in-gated-category");
    this.set("hidden", false);
  }

  @computed("hidden")
  get shouldShow() {
    return !this.hidden;
  }

  get showGroupGate() {
    return this.currentUser && this.enabledGroups.length > 0;
  }

  <template>
    {{#if this.shouldShow}}
      <div class="custom-gated-topic-container">
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{#if this.showGroupGate}}
              {{i18n (themePrefix "group_subheading_text")}}
            {{else}}
              {{i18n (themePrefix "subheading_text")}}
            {{/if}}
          </p>

          <div class="custom-gated-topic-content--cta">
            {{#if this.showGroupGate}}
              <div class="custom-gated-topic-content--cta__group">
                {{#if settings.group_custom_button_link}}
                  <DButton
                    @href={{settings.group_custom_button_link}}
                    class="btn-primary btn-large"
                    @translatedLabel={{i18n (themePrefix "group_cta_label")}}
                  />
                {{/if}}
              </div>
            {{else}}
              <div class="custom-gated-topic-content--cta__signup">
                <DButton
                  @action={{routeAction "showCreateAccount"}}
                  class="btn-primary btn-large sign-up-button"
                  @translatedLabel={{i18n (themePrefix "signup_cta_label")}}
                />
              </div>

              <div class="custom-gated-topic-content--cta__login">
                <DButton
                  @action={{routeAction "showLogin"}}
                  @id="cta-login-link"
                  class="btn btn-text login-button"
                  @translatedLabel={{i18n (themePrefix "login_cta_label")}}
                />
              </div>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
