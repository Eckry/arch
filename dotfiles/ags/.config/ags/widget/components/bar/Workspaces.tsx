import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"
import { createBinding, For } from "gnim"
import { iconMap } from "../../consts"

function getIcon(className: string) {
  return Object.hasOwn(iconMap, className) ? iconMap[className as keyof typeof iconMap] : iconMap.default
}

export default function Workspaces() {
  const hypr = Hyprland.get_default()

  const workspaces = createBinding(hypr, "workspaces").as(workspaces =>
    [...workspaces].sort((a, b) => a.id - b.id)
  )

  const focusedWorkspace = createBinding(hypr, "focusedWorkspace")

  return (
    <box $type="start" spacing={7}>
      <For each={workspaces}>
        {(workspace) => {
          const active = focusedWorkspace.as(
            focused => focused?.id === workspace.id
          )

          const clients = createBinding(workspace, "clients")

          const icon = clients.as(clients => {
            const client = clients[0]
            const className = client?.class
            return getIcon(className)
          })

          return (
            <button
              valign={Gtk.Align.CENTER}
              halign={Gtk.Align.CENTER}
              class={active.as(
                active =>
                  `workspace ${active ? "workspace-active" : ""}`
              )}
            >
              {icon ? (
                <image
                  file={icon}
                  pixelSize={20}
                />
              ) : (
                <label label="X" />
              )}
            </button>
          )
        }}
      </For>
    </box>
  )
}

