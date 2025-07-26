import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Gated Topics - Anonymous", function (needs) {
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_tags = "foo|baz";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_tags = "";
  });

  test("Viewing Topic in gated category", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".topic-in-gated-category .custom-gated-topic-content")
      .exists("gated category prompt shown for anons on selected category");
  });

  test("Viewing Topic in non-gated category", async function (assert) {
    await visit("/t/34");

    assert
      .dom(".topic-in-gated-category .custom-gated-topic-content")
      .doesNotExist(
        "gated category prompt shown for anons on selected category"
      );
  });

  test("Viewing Topic with gated tag", async function (assert) {
    await visit("/t/2480");

    assert
      .dom(".topic-in-gated-category .custom-gated-topic-content")
      .exists(
        "gated category prompt shown for anons on topic with selected tag"
      );
  });
});

acceptance("Gated Topics - Logged In", function (needs) {
  needs.user();
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_tags = "foo|baz";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_tags = "";
  });

  test("Viewing Topic in gated category", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".topic-in-gated-category .custom-gated-topic-content")
      .doesNotExist("gated category prompt not shown on selected category");
  });

  test("Viewing Topic with gated tag", async function (assert) {
    await visit("/t/2480");

    assert
      .dom(".topic-in-gated-category .custom-gated-topic-content")
      .doesNotExist(
        "gated category prompt not shown on topic with selected tag"
      );
  });
});
