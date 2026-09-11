import { createBinding } from "ags"
import { Gtk } from "ags/gtk4"
import astalBattery from "gi://AstalBattery"

export default function Battery() {
  const battery = astalBattery.get_default()
  const percentage = createBinding(battery, "percentage")

  return (
    <box
      $type="end"
      class="BatteryBox"
      valign={Gtk.Align.CENTER}
    >
      <box
        class="BatteryBar"
        orientation={Gtk.Orientation.VERTICAL}
      >
        {Array.from({ length: 5 }, (_, i) => {
          const threshold = (5 - i) / 5

          return (
            <box
              class="BatteryLine"
              opacity={percentage.as(p =>
                p >= threshold ? 1 : 0
              )}
            />
          )
        })}
      </box>

      <label
        class="BatteryText"
        label={percentage.as(p => `${Math.round(p * 100)}%`)}
      />
    </box>
  )
}
