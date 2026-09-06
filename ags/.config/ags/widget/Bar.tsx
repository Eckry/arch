import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createBinding } from "ags"
import { createPoll } from "ags/time"
import Battery from "gi://AstalBattery"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, () => new Date().toLocaleString())

  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const battery = Battery.get_default()
  const percentage = createBinding(battery, "percentage")

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <menubutton
          name="date"
          class="Date"
          $type="center"
          hexpand
          halign={Gtk.Align.CENTER}
        >
          <label label={time} />

          <popover>
            <Gtk.Calendar />
          </popover>
        </menubutton>

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
      </centerbox>
    </window>
  )
}
