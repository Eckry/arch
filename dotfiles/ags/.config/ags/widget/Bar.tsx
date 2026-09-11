import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import Battery from "./components/bar/Battery"
import Time from "./components/bar/Time"
import Volume from "./components/bar/Volume"
import Workspaces from "./components/bar/Workspaces"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor


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

        <Workspaces />
        <Time />
        <box spacing={15} class="utils" $type="end">
          <Volume />
          <Battery />
        </box>

      </centerbox>
    </window>
  )
}
