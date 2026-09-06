import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"

export default function Time() {
  const time = createPoll("", 1000, () => new Date().toLocaleString())

  return (<menubutton
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
  </menubutton>)
}
