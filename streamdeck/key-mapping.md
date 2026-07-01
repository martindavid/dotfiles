# Stream Deck Plus — AeroSpace Key Mapping

Stream Deck Plus has 8 LCD keys (4×2) and 4 rotary dials. All actions use
**Hotkey** actions in the Elgato Stream Deck app — no plugins required.
The keys send keystroke sequences that AeroSpace intercepts.

## 8 LCD Keys

| Position | Label         | Action type    | Keystroke(s)                    | AeroSpace command                  |
|----------|---------------|----------------|---------------------------------|------------------------------------|
| 1,1      | Focus ←       | Hotkey         | `alt+h`                         | `focus left`                       |
| 1,2      | Focus →       | Hotkey         | `alt+l`                         | `focus right`                      |
| 1,3      | Focus ↑       | Hotkey         | `alt+k`                         | `focus up`                         |
| 1,4      | Focus ↓       | Hotkey         | `alt+j`                         | `focus down`                       |
| 2,1      | Balance       | Hotkey         | (bind a key, see note below)    | `balance-sizes`                    |
| 2,2      | Float toggle  | Hotkey         | (service mode: `alt+shift+;` then `f`) | `layout floating tiling`    |
| 2,3      | Share ON      | Multi Action   | `alt+shift+p` then `s`          | runs `share-on.sh`, 16:9 band      |
| 2,4      | Share OFF     | Multi Action   | `alt+shift+p` then `f`          | runs `share-off.sh`, full width    |

### Notes

**Multi Action (Share ON/OFF):** In Stream Deck, create a "Multi Action" with two
consecutive "Hotkey" steps. Add a 100ms delay between them so AeroSpace has time
to enter `share` mode before the second key arrives.

**Balance sizes:** `balance-sizes` has no default binding. Either add one to
`.aerospace.toml` (e.g. `alt-shift-b = 'balance-sizes'`) and use that here, or
use the service mode: `alt+shift+;` then `r` (which currently does `flatten-workspace-tree`).

**Workspace switching (optional):** `alt+1` through `alt+9` and `alt+a`, `alt+s`, etc.
can also be mapped to additional Stream Deck keys or pages for direct workspace jumping.

## 4 Rotary Dials

Dials use **Hotkey** actions for rotation (turn left = one keystroke, turn right = another):

| Dial | Turn CW        | Turn CCW       | Press           |
|------|----------------|----------------|-----------------|
| 1    | `alt+shift+=`  | `alt+shift+-`  | `alt+/` (tiles) |
| 2–4  | (unassigned)   | (unassigned)   | (unassigned)    |

Dial 1 maps to resize: `alt+shift+=` = `resize smart +50`, `alt+shift+-` = `resize smart -50`.
Dial 1 press maps to `alt+/` = `layout tiles horizontal vertical`.

## How to configure in Stream Deck app

1. Open Stream Deck → select the key → choose **Hotkey** action.
2. Click the keystroke field and press the key combination on your keyboard.
3. For Multi Action: choose **Multi Action** → drag in two **Hotkey** actions → set a
   100ms delay on the second step.
4. For dials: select the dial slot → configure **Rotate Right**, **Rotate Left**, and
   **Press** tabs separately, each with a Hotkey action.
