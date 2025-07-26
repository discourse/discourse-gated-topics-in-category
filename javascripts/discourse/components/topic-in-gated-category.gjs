import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@tagName("")
export default class TopicInGatedCategory extends Component {
  hidden = true;
  enabledCategories = settings.enabled_categories
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => id);
  enabledTags = settings.enabled_tags.split("|").filter(Boolean);

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
    // do nothing if:
    // a) topic does not have a category and does not have a gated tag
    // b) component setting is empty
    // c) user is logged in
    const gatedByTag = this.tags?.some((t) => this.enabledTags.includes(t));

    if (
      (!this.categoryId && !gatedByTag) ||
      (this.enabledCategories.length === 0 && this.enabledTags.length === 0) ||
      this.currentUser
    ) {
      return;
    }

    if (this.enabledCategories.includes(this.categoryId) || gatedByTag) {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
    }
  }

  @discourseComputed("hidden")
  shouldShow(hidden) {
    return !hidden;
  }

  <template>
    {{#if this.shouldShow}}
      <div class="custom-gated-topic-container">
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{i18n (themePrefix "subheading_text")}}
          </p>

          <div class="custom-gated-topic-content--cta">
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
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
