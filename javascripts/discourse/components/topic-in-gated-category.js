import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

const enabledCategories = settings.enabled_categories
  .split("|")
  .map((id) => parseInt(id, 10))
  .filter((id) => id);

const enabledTags = settings.enabled_tags.split("|");

export default Component.extend({
  tagName: "",
  hidden: true,
  gatedByTag: false,

  didInsertElement() {
    this._super(...arguments);
    this.recalculate();
  },

  didUpdateAttrs() {
    this._super(...arguments);
    this.recalculate();
  },

  willDestroyElement() {
    document.body.classList.remove("topic-in-gated-category");
  },

  recalculate() {
    // do nothing if:
    // a) topic does not have a category and does not have a gated tag
    // b) component setting is empty
    // c) user is logged in
    this.gatedByTag = this.tags.some((t) => enabledTags.indexOf(t) >= 0);

    if (
      (!this.categoryId && !this.gatedByTag) ||
      (enabledCategories.length === 0 && enabledTags.length === 0) ||
      this.currentUser
    ) {
      return;
    }

    if (enabledCategories.includes(this.categoryId) || this.gatedByTag) {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
    }
  },

  @discourseComputed("hidden")
  shouldShow(hidden) {
    return !hidden;
  },
});
