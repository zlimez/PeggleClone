# CS3217 Problem Set 2

**Name:** Chiu Chi Kuan

**Matric No:** A0234100E

## Tips
1. CS3217's docs is at https://cs3217.github.io/cs3217-docs. Do visit the docs often, as
   it contains all things relevant to CS3217.
2. A Swiftlint configuration file is provided for you. It is recommended for you
   to use Swiftlint and follow this configuration. We opted in all rules and
   then slowly removed some rules we found unwieldy; as such, if you discover
   any rule that you think should be added/removed, do notify the teaching staff
   and we will consider changing it!

   In addition, keep in mind that, ultimately, this tool is only a guideline;
   some exceptions may be made as long as code quality is not compromised.
3. Do not burn out. Have fun!

## Notes
If you have changed the specifications in any way, please write your
justification here. Otherwise, you may discard this section.

## Dev Guide
You may put your dev guide either in this section, or in a new file entirely.
You are encouraged to include diagrams where appropriate in order to enhance
your guide.

## Tests
If you decide to write how you are going to do your tests instead of writing
actual tests, please write in this section. If you decide to write all of your
tests in code, please delete this section.

## Written Answers

### Design Tradeoffs
> When you are designing your system, you will inevitably run into several
> possible implementations, in which you need to choose one among all. Please
> write at least 2 such scenarios and explain the trade-offs in the choices you
> are making. Afterwards, explain what choices you choose to implement and why.
>
> For example (might not happen to you -- this is just hypothetical!), when
> implementing a certain touch gesture, you might decide to use the method
> `foo` instead of `bar`. Explain what are the advantages and disadvantages of
> using `foo` and `bar`, and why you decided to go with `foo`.

To prevent collision of two pegs, I thought of two options.
1. Check the moving/added peg against all pegs on the board
2. Divide the board into a grid whose cell height and width are equal to the 
   radius of a peg, then check only the pegs in the 5x5 subgrid neighbourhood centered
   on the moving/added peg
Option 1 is simpler to implement and permits struct to be used to represent the pegs
However, the time complexity of adding n pegs is O(n^2) and dragging a peg over m intervals
is O(mn). On the other hand option 2 is more complicated to implement and prefers a class 
implementation to maintain identical reference between the pegs populating the grid and the pegs
in the peg list which the board view UI depends upon. The advantage is that it enables linear 
time for addition and O(m) for dragging of pegs. I opted for option 2, as I thought it would b
interesting to grant level designers the freedom to create and modify complicated maps without 
any lag and performance degradation.

As per the specification, I need to detect whether a tapping occurs on a peg or an unoccupied
player area. Ideally, I would like to detect a tap in the game area, then determine the response
based on the state of the BoardViewModel with a single method (to delete a peg, to add a peg). 
In this tap handler, I will need to custom detect if the tap occurs on a peg. Given swiftUI's support 
for detecting gesture on a view component itself, I instead had the two tap detections handled by
two methods, which reduced the code I need to write.

### Persistence Justification
> Please justify your choice of persistence method in your `README.md`. In
> other words, write your considerations in weighing the pros and cons of the
> persistence methods you have considered.

I chose to encode and decode from a file. Encoding and decoding from a file is similar to
using a NoSQL database of which I have experience in. Furthermore, swift's codable protocol
makes the implementation simpler. Where this option suffers is the lack of schema present in
SQL databases which can check the integrity of the data the game saves and prevent corruption.
I do not have much of an understanding of Core data, but given it requires a schema to, it will
add to the amount of effort required to ensure data persistence just like SQL databases.
