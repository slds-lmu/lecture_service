# lecture_service

Service repo for common infrastructure across all open source lectures


## Structure (WIP)

- `[service](service)`: Meta-components not meant to be disseminated across dependant repositories
	- `/bin`: Scripts used for CI or locally to perform various maintenance tasks
	- `lecture_repos.txt`: Text file with GitHub URLs of dependant lecture repos. Not sure yet how we keep track of those but at some point CI will need a definitive list that's easy to work with. Not sure if it shoul dbe JSON or something.
- `[style](style)`: The top-level `style` folder in `lecture_*` repos defining crucial components such as the LaTeX preamble and `lmu-lecture.sty`.
