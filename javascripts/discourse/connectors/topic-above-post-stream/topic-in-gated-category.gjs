import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import TopicInGatedCategory from "../../components/topic-in-gated-category";

@classNames("topic-above-post-stream-outlet", "topic-in-gated-category")
export default class TopicInGatedCategoryConnector extends Component {
  <template>
    <TopicInGatedCategory
      @categoryId={{this.model.category_id}}
      @tags={{this.model.tags}}
    />
  </template>
}
