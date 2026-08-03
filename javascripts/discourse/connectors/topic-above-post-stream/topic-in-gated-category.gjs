import Component from "@glimmer/component";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import bodyClass from "discourse/helpers/body-class";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";

export default class TopicInGatedCategory extends Component {
  @service currentUser;

  get enabledCategories() {
    return settings.enabled_categories
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter((id) => id);
  }

  get enabledTags() {
    return settings.enabled_tags.split("|").filter(Boolean);
  }

  get enabledGroups() {
    return settings.enabled_groups
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter((id) => !isNaN(id));
  }

  get userInEnabledGroups() {
    if (Object.hasOwn(settings, "user_in_enabled_groups")) {
      return settings.user_in_enabled_groups;
    } else {
      // TODO (martin) Remove this fallback after resolve_group_membership
      // from core is available everywhere
      return this.currentUser?.groups?.some((g) =>
        this.enabledGroups.includes(g.id)
      );
    }
  }

  get shouldShow() {
    // user is in an enabled group — always bypass
    if (this.userInEnabledGroups) {
      return false;
    }

    const gatedByCategory = this.enabledCategories.includes(
      this.args.outletArgs.model.category_id
    );

    const gatedByTag = this.args.outletArgs.model.tags?.some((t) =>
      this.enabledTags.includes(t.name)
    );

    const hasAnyCategoryOrTag =
      this.enabledCategories.length > 0 || this.enabledTags.length > 0;

    if (!hasAnyCategoryOrTag && !this.groupGatingEnabled) {
      return false;
    }

    // when categories/tags are configured, topic must match one
    if (hasAnyCategoryOrTag && !gatedByCategory && !gatedByTag) {
      return false;
    }

    if (!this.showGroupGate && this.currentUser) {
      return false;
    }

    return true;
  }

  get groupGatingEnabled() {
    return settings.enable_gating_with_groups;
  }

  get showGroupGate() {
    return Boolean(this.currentUser && this.groupGatingEnabled);
  }

  <template>
    {{#if this.shouldShow}}
      {{bodyClass "topic-in-gated-category"}}

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
