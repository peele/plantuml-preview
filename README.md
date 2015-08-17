# PlantUML Preview
Package for using [PlantUML](http://plantuml.com/index.html) to create rendered uml diagrams and display.

![plantuml-preview screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/plantuml-preview.png)

![multipage screenshot](https://raw.githubusercontent.com/peele/plantuml-preview/master/multipage.png)

Screenshots shown with: [language-plantuml](https://atom.io/packages/language-plantuml), [nucleus-dark-ui](https://atom.io/themes/nucleus-dark-ui), [polaris-syntax](https://atom.io/themes/polaris-syntax), [minimap](https://atom.io/packages/minimap)

## Features
- Generate png image(s) and display in split pane
  - Images are only generated on preview toggle if the expected image files do not exist or are out of date
  - Regenerate on save
- Supports multipage diagrams
  - `newpage` within `@startuml`/`@enduml`  
  - multiple `@startuml`/`@enduml` within file
  - Combinations of both
- Handling of `@startuml filename`
- Charset of the text editor will be passed to PlantUML
- Zoom to fit option
  - Configuration setting for initial value
  - Checkbox control for each preview
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
- `Java`: Path to java executable
- `Use Temp Directory`: Output diagrams to OS temporary directory, default = false
- `Zoom To Fit`: The initial setting for new preview panes, default = true

## Possible Future Improvements
- Scaled zooming
- Copy preview image from pane
- Support for additional output formats
