import { Gtk } from "ags/gtk4"
import { type Accessor } from "ags"

interface Props {
  depth: Accessor<number>
}

export default function VolumeLine({ depth }: Props) {
  let widgetTree = (
    <box
      class="volume-dot"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    />
  )

  for (let i = 1; i <= 5; i++) {
    widgetTree = (
      <box
        class={depth((level) => `volume-ring ${i <= level ? "active" : ""}`)}
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
      >
        {widgetTree}
      </box>
    )
  }

  return (
    <box
      class="volume-container"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      {widgetTree}
    </box>
  )
}
