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

**Unit tests**
I have written unit tests for `Peg`, `Board`, `PegViewModel` and `BoardViewModel`
under the folder PeggleTests.

Unit tests for `Levels` and `DataManager` will be described below instead.

For `DataManager`, I will create a stub struct `foo` conforming to the `Codable` and `Equatable` 
protocal with two properties `bar` of type `String` and `bob` of type `Int`.

- `DataManager`
   `save` and `load` method
   1. Invoke `save` passed with a `foo` object and a file name `foo.json`
   2. Check `foo.json` exists at `documentDirectory` with `FileManager`
   3. Invoke `load` passed with the same file name `foo.json`
   4. Check equality between the loaded `foo` object and the original `foo` object

- `Levels`
   `saveLevel` and `loadLevel` method
   1. Create a `Levels` object and invoke `saveLevel` with a `Board` object and level name `Trial`
   2. Invoke `loadLevel` with the same level name `Trial` and store the result in another `Board` object
   3. Assert that the two `Board` objects' property `allPegs` are equal
   4. Create another `Levels` object and invoke `loadLevel` on this object
   5. Assert that both `Levels` objects' `levelTable` contains `Trial` key and that the paired `Board` objects' `allPegs` properties are equal.

**Integration tests**

- Blue peg button
1. When tapped, the button should light up. The orange peg button and delete button should dim.
2. Tap on the empty board, a blue peg should appear.
3. Tap near the board's edge, no pegs should appear.
4. Tap near the blue peg, no pegs should appear.

- Orange peg button
1. When tapped, the button should light up. The the blue peg button and delete button should dim.
2. Tap on an open area on the board, an orange peg should appear.
3. Tap near the board's edge, no pegs should appear.
4. Tap near a peg on the board, no pegs should appear.

- Delete button
1. When tapped, the delete button should light up. The blue and orange peg button should dim.
2. Tap an empty area on the board, nothing should change.
3. Tap on a peg, the peg should be removed from the board.

- Peg
1. When long pressed, the peg should be removed from the board.
2. When dragged, the peg should follow the finger's movement.
3. When dragged to the edge of the board, the peg should stop.
4. When dragged to collide with another peg, the peg should stop.

- Reset button
1. When tapped, all pegs on the board should be removed.

- Level name text field
1. The characters in the field should match user input.

- Save and load button
1. Create several pegs on the arrange them as pleased.
2. Type _Picasso_ into the text field.
3. Press the Save button.
4. Press the Reset button.
5. Press the Load button (The text in the text field should still be _Picasso_)
6. The pegs arrangement you saved under _Picasso_ should appear.
7. Drag the pegs on the board around.
8. Delete a few but not all of the pegs.
9. Add some extra pegs to the board.
10. Clear the text field and enter _Van Gogh_.
11. Press the save button.
12. Enter _Picasso_ into the text field and press Load.
13. The _Picasso_ pegs arrangement should appear again.
14. Enter _Van Gogh_ into the text field and press Load.
15. The _Van Gogh_ pegs arrangement should appear again.
16. Drag, delete or add some pegs to the board.
17. Press Save (The text in the text field should still be _Van Gogh_)
18. Press Reset.
19. Drag, delete or add some pegs to the board.
20. Clear the text field, press Save and press Load.
22. All pegs on the board should be removed.
23. Enter _Van Gogh_ in the text field and press Load.
24. The updated pegs arrangement under _Van Gogh_ should appear.
25. Exit the app, and ensure all its processes are terminated.
26. Reopen the app, enter _Picasso_ or _Van Gogh_ into the text field and press Load.
27. Their respective pegs arrangement as per what was saved in the previous session should appear.

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

I chose to encode and decode from a file due to its similarity with using a NoSQL database 
which I have prior experience in. Swift's `Codable` protocol makes the implementation straight 
forward. The way I structure my class and structs is the blueprint of the data organization.

However, the method lacks a schema present in SQL databases and ORMs. Hence, the integrity of data
is not enforced which can result in malformed data that cannot be parsed by the application later.
Another consideration that informed my choice is the stage of development I am in now. Models can
still be refactored or extended. If I chose SQL or ORM I will need to update the schema as class and
struct specifications change, slowing the development speed.
