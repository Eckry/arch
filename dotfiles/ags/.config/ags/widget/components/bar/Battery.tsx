import { createBinding } from "ags"
import { Gtk } from "ags/gtk4"
import astalBattery from "gi://AstalBattery"
import { BATTERY_CHARGING_STATE } from "../../consts"

export default function Battery() {
  const battery = astalBattery.get_default()

  const percentage = createBinding(battery, "percentage")
  const state = createBinding(battery, "state")

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
              class={state.as(s =>
                s === BATTERY_CHARGING_STATE
                  ? "BatteryLine battery-charging"
                  : "BatteryLine"
              )}
              opacity={percentage.as(p =>
                p >= threshold ? 1 : 0
              )}
            />
          )
        })}
      </box>

      <label
        class="BatteryText numeric"
        label={percentage.as(p =>
          `${Math.round(p * 100)}%`
        )}
      />
    </box>
  )
}
