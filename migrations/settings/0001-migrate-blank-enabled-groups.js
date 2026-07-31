export default function migrate(settings) {
  if (
    settings.has("enabled_groups") &&
    !String(settings.get("enabled_groups") ?? "").trim()
  ) {
    settings.set("enabled_groups", "5");
  }

  return settings;
}
