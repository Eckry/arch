import Wp from "gi://AstalWp"
import { createBinding } from "ags"
import VolumeLine from "./VolumeLine"

export default function Volume() {
  const wp = Wp.get_default()
  const speaker = wp.audio.default_speaker

  const depth = createBinding(speaker, "volume")(
    (vol) => {
      const level = Math.round((vol ?? 0) * 5)
      return Math.max(0, Math.min(5, level))
    }
  )

  return (
    <box class="volumebox">
      <VolumeLine depth={depth} maxRings={5} />
    </box>
  )
}
