import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"
import { createBinding, For } from "gnim"

export default function Workspaces() {
  const hypr = Hyprland.get_default()

  const workspaces = createBinding(hypr, "workspaces").as(workspaces => {
    return [...workspaces].sort((a, b) => a.id - b.id)

  })
  const focusedWorkspace = createBinding(hypr, "focusedWorkspace")

  return (
    <box $type="start" spacing={7}>
      <For each={workspaces}>
        {(workspace) => {
          const active = focusedWorkspace.as(
            (focused) => focused?.id === workspace.id
          )

          return (
            <button
              valign={Gtk.Align.CENTER}
              halign={Gtk.Align.CENTER}
              class={active.as(
                (active) =>
                  `workspace ${active ? "workspace-active" : ""}`
              )}
            />
          )
        }}
      </For>
    </box>
  )
}
