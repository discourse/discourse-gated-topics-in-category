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

acceptance("Gated Topics - User in Allowed Group", function (needs) {
  needs.user({
    groups: [{ id: 42, name: "premium" }],
  });
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_groups = "42";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_groups = "";
  });

  test("no gate shown for user in allowed group", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".custom-gated-topic-content")
      .doesNotExist("gate not shown when user is in the allowed group");
  });
});

acceptance("Gated Topics - User NOT in Allowed Group", function (needs) {
  needs.user({
    groups: [{ id: 99, name: "other" }],
  });
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_groups = "42";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_groups = "";
  });

  test("gate shown with group subheading and no CTA button", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".custom-gated-topic-content")
      .exists("gate shown when user is not in the allowed group");

    assert
      .dom(".custom-gated-topic-content--cta__group")
      .doesNotExist("no group CTA button when custom_button_link is empty");

    assert
      .dom(".custom-gated-topic-content--cta__signup")
      .doesNotExist("signup CTA not shown for logged-in user");
  });
});

acceptance("Gated Topics - User NOT in Group with Custom Link", function (needs) {
  needs.user({
    groups: [{ id: 99, name: "other" }],
  });
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_groups = "42";
    settings.custom_button_link = "https://example.com/subscribe";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_groups = "";
    settings.custom_button_link = "";
  });

  test("gate shown with custom CTA button", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".custom-gated-topic-content--cta__group .btn-primary")
      .exists("group CTA button is shown when custom link is set");

    assert
      .dom(".custom-gated-topic-content--cta__group .btn-primary")
      .hasAttribute(
        "href",
        "https://example.com/subscribe",
        "CTA uses custom button link"
      );
  });
});

acceptance("Gated Topics - User in One of Multiple Groups", function (needs) {
  needs.user({
    groups: [{ id: 99, name: "vip" }],
  });
  needs.settings({ tagging_enabled: true });
  needs.hooks.beforeEach(function () {
    settings.enabled_categories = "2";
    settings.enabled_groups = "42|99";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_categories = "";
    settings.enabled_groups = "";
  });

  test("no gate shown for user in one of multiple allowed groups", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".custom-gated-topic-content")
      .doesNotExist("gate not shown when user is in one of the allowed groups");
  });
});

acceptance("Gated Topics - Groups Only (no categories or tags)", function (needs) {
  needs.user({
    groups: [{ id: 99, name: "other" }],
  });
  needs.hooks.beforeEach(function () {
    settings.enabled_groups = "42";
  });

  needs.hooks.afterEach(function () {
    settings.enabled_groups = "";
  });

  test("gate shown on any topic when only groups configured", async function (assert) {
    await visit("/t/internationalization-localization/280");

    assert
      .dom(".custom-gated-topic-content")
      .exists("gate shown even without category/tag settings");
  });
});
