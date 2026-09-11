import Wp from "gi://AstalWp"
import { createBinding, createMemo, With } from "ags"
import { VolumeHigh, VolumeLow, VolumeMedium, VolumeMuted } from "../../icons"

export default function Volume() {
  const wp = Wp.get_default()
  const speaker = wp.audio.default_speaker

  const volume = createBinding(speaker, "volume")
  const mute = createBinding(speaker, "mute")

  const volumeIcon = createMemo(() => {
    const vol = volume()
    const isMuted = mute()

    if (isMuted || vol <= 0)
      return <VolumeMuted />
    else if (vol <= 0.3)
      return <VolumeLow />
    else if (vol <= 0.6)
      return <VolumeMedium />
    else
      return <VolumeHigh />
  })

  return (
    <box>
      <With value={volumeIcon}>
        {(icon) => icon}
      </With>

      <With value={volume}>
        {(vol) => <label class="numeric volume-text bold color-accent" label={`${Math.round(vol * 100)}%`} />}
      </With>
    </box>
  )
}
