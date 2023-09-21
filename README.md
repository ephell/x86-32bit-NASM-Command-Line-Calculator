![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ephell/x86-32bit-NASM-Command-Line-Calculator)
![GitHub last commit (by committer)](https://img.shields.io/github/last-commit/ephell/x86-32bit-NASM-Command-Line-Calculator)
# ⌨️ Command Line Calculator 
A command line calculator app written in x86 32-bit NASM on Linux. The goal of this project was to teach myself the basics of Assembly.

## Features
- Performs basic arithmetic operations (addition, subtraction, multiplication, division).
- Verifies user input to ensure it is in a valid format.
- Supports negative numbers.
- Displays division result with up to 10 decimal places.
- Displays various error messages.
- Utilizes separator lines, menu options, prompts and more to structure and organize the user interface for clarity.

## Limitations
- Doesn't support results larger than 32 bits.
- Doesn't support operands larger than 32 bits.
- Doesn't support decimal operands.

## Demo
![Demo GIF](https://i.imgur.com/jEr5al2.gif)

## Installation & Usage
1. Open a terminal.
2. Install NASM: `sudo apt install nasm`
3. Clone the repository: `git clone [repository URL]`
4. Navigate to the project directory: `cd [project directory path]`
5. Run `make` to compile the program.
6. Run `./main` to run the program.

## License
[MIT](https://choosealicense.com/licenses/mit/)
