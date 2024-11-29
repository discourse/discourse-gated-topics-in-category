import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import discourseComputed from "discourse-common/utils/decorators";

const enabledCategories = settings.enabled_categories
  .split("|")
  .map((id) => parseInt(id, 10))
  .filter((id) => id);

const enabledTags = settings.enabled_tags.split("|").filter(Boolean);

@tagName("")
export default class TopicInGatedCategory extends Component {
  hidden = true;

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
    const gatedByTag = this.tags?.some((t) => enabledTags.includes(t));

    if (
      (!this.categoryId && !gatedByTag) ||
      (enabledCategories.length === 0 && enabledTags.length === 0) ||
      this.currentUser
    ) {
      return;
    }

    if (enabledCategories.includes(this.categoryId) || gatedByTag) {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
    }
  }

  @discourseComputed("hidden")
  shouldShow(hidden) {
    return !hidden;
  }
}
