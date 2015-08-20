# 0.7.0
- Global `Output Format` setting with png and svg options, default svg
- Per preview control for output format
- Changed `Use Temp Directory` default to true

# 0.6.0
- `Use Temp Directory` global setting and per preview control
- Only tested on OS X

# 0.5.1
- `Bring To Front` defaulted to false
- *This feature may be removed, clarification:*
  - Put it in due to annoyance with the `window:focus-next-pane`/ `pane:show-next-item` workflow and fuzzy-finder not showing all open items
  - Toggling the preview accomplishes the same outcome due to files only regenerating if required
  - Does preserve the state (zoom and such) of the preview, which toggling would lose, but there are probably other ways to deal with this issue (serialization?)

# 0.5.0
- Bring To Front feature, not sure about it, defaulted to true
- Minor refactor

# 0.4.0
- 'Zoom To Fit' default set to true
- Added 'Display Filename Above UML Diagrams', default true

# 0.3.1
- Fix issue #2 - Preview does not scroll on windows.

# 0.3.0
- Handle filename provided with @startuml
- Handle multiple @startuml/@enduml in single file

# 0.2.0
- Added config setting for Graphviz dot location
- Support for displaying multipage uml diagrams

# 0.1.1
- Update README and project description
- Fix issue #1 - 'Zoom To Fit' set on file save.

# 0.1.0 - First Release
- Every feature added
- Every bug fixed
