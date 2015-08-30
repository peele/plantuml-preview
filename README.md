# PlantUML Preview
Package for using [PlantUML](http://plantuml.com/index.html) to create rendered uml diagrams and display.

![plantuml-preview screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/plantuml-preview.png)

![multipage screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/multipage.png)

Screenshots shown with: [language-plantuml](https://atom.io/packages/language-plantuml), [nucleus-dark-ui](https://atom.io/themes/nucleus-dark-ui), [polaris-syntax](https://atom.io/themes/polaris-syntax), [minimap](https://atom.io/packages/minimap)

## Features
- Generate diagrams and display in split pane
  - Output formats: svg, png
  - Images are only generated on preview toggle if the expected image files do not exist or are out of date
  - Regenerate on save
- Supports multipage diagrams
  - `newpage` within `@startuml`/`@enduml`  
  - Multiple `@startuml`/`@enduml` within file
  - Combinations of both
- Handling of `@startuml filename`. Images may not display if the extension on the filename does not match the output format.
- Charset of the text editor will be passed to PlantUML
- Zoom to fit option
  - Configuration setting for initial value
  - Checkbox control for each preview
- Scaled zooming
  - Maintained when regenerating on save
  - Maintained when output format is changed
- Use temporary directory option
  - Configuration setting for initial value
  - Checkbox control for each preview

## Configuration
- `Bring To Front`: Bring preview to front when parent editor gains focus
  - Default = false
  - Works best if `fuzzy-finder:Search All Panes` = true
  - *See [CHANGELOG](https://github.com/peele/plantuml-preview/blob/master/CHANGELOG.md), don't know if this feature is necessary*
- `Display Filename Above UML Diagrams`: Default = true
- `Graphviz Dot Location`: Path to dot executable, [Graphviz](http://www.graphviz.org/)
- `PlantUML Jar Location`: Path to PlantUML jar
- `Java Command`: Command for executing Java
- `Output Format`: Select png or svg output, default = svg
- `Use Temp Directory`: Output diagrams to OS temporary directory, default = true
- `Zoom To Fit`: The initial setting for new preview panes, default = true

## Possible Future Improvements
- Copy diagram from pane
  - `Clipboard.writeImage` looks like it is currently not supported in the atom api
  - The Electron api has it listed, maybe support will be added in a future update
