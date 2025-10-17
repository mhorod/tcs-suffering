# tcs-suffering

Notes from subjects taught on the [Theoretical Computer Science course at Jagiellonian University](https://tcs.uj.edu.pl/en_GB).

Currently, this repository contains notes for the following:
- `dyskretna` – Discrete Mathematics (Matematyka Dyskretna)
- `systemy-operacyjne` – Operating Systems (Systemy Operacyjne)
- `mpumy` – Probabilistic Methods in Machine Learning (Metody Probabilistyczne w Uczeniu Maszynowym)
- `aatl` – Algorithms in Algebra and Number Theory (Algorytmy Algebry i Teorii Liczb)
- `probabil` – Probabilistic Methods in Computer Science (Metody Probabilistyczne Informatyki)
- `probabil-2025` - Probabilistic Methods in Computer Science, in the 2025 lecture order
- `modele` – Models of Computation (Modele Obliczeń); incomplete
- `licencjat` – Final exam for the licencjat degree; incomplete

## Releases
You can find the latest generated versions of the documents
available for download [at the "PDFs" GitHub release](https://github.com/mhorod/tcs-suffering/releases/tag/pdfs).

## Contributing
Here's a quick primer on how to work on the notes in the repository:
- Clone the repository
- Install LaTeX (if you are on Ubuntu: `sudo apt-get install texlive-full` will do the trick)
- Run `./build-one.sh {subject}` to build the PDF for the subject
- Get your pdf from `./build/{subject}/main.pdf`
- Make your preferred changes to the files in the `{subject}` directory
  - When creating new subjects, it is strongly suggested to copy the `example` directory and adapt from there – also don't forget to add it to this README
  - Also please familiarize yourself with the common packages placed in the (intuitively named) `common` directory
- Repeat the build process until you are satisfied with the result

When you are ready to contribute your changes:
- Verify that the build script doesn't fail prematurely (does it output **`succesfully compiled {subject}`** at the end?)
- Run `./format.sh {subject}` to reformat all the documents with `latexindent`
- Fork the repository, push your changes and submit your pull request [to the main repository](https://github.com/mhorod/tcs-suffering/pulls).
  - More details about creating pull requests are available in the [GitHub documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
- *Don't forget to add a funny "Ponton" nickname to the titlepage ;)*

## License
All the notes are provided under the [Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0) license.
