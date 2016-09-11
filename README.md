# PlantUML Preview
Package for using [PlantUML](http://plantuml.com/index.html) to create rendered uml diagrams and display.

![plantuml-preview screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/plantuml-preview.png)

![multipage screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/multipage.png)

Screenshots shown with: [language-plantuml](https://atom.io/packages/language-plantuml), [nucleus-dark-ui](https://atom.io/themes/nucleus-dark-ui), [polaris-syntax](https://atom.io/themes/polaris-syntax), [minimap](https://atom.io/packages/minimap)

## Features
- Generate diagrams and display in split pane
  - Output formats: svg, png
  - Context menu command to copy diagram
    - SVG as XML
    - PNG as PNG
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
- `Beautify XML`: Use js-beautify on XML when copying and generating SVG diagrams, probably pointless, default = true
- `Bring To Front`: Bring preview to front when parent editor gains focus
  - Default = false
  - Works best if `fuzzy-finder:Search All Panes` = true
  - *See [CHANGELOG](https://github.com/peele/plantuml-preview/blob/master/CHANGELOG.md), don't know if this feature is necessary*
- `Display Filename Above UML Diagrams`: Default = true
- `Graphvis Dot Executable`: Path of dot executable, [Graphviz](http://www.graphviz.org/)
- `Additional PlantUML Arguments`: Free form text field for additional arguments to PlantUML. Added immediately after the `-jar` argument.
- `PlantUML Jar`: Path of PlantUML jar
- `Java Executable`: Path of Java executable, default = java
- `Additional Java Arguments`: Free form text field for additional arguments for java call.
- `Output Format`: Select png or svg output, default = svg
- `Use Temp Directory`: Output diagrams to OS temporary directory, default = true
- `Zoom To Fit`: The initial setting for new preview panes, default = true

## Possible Future Improvements
- Option to copy SVG diagrams as XML or PNG
- Improved README
- FAQ
- Tests
