# Pocket Change
IOS App made from scratch that helps users manage their personal expenses and log their day-to-day transactions

# Features
‣ Create a budget with a name and starting balance <br />
‣ Spend or add money to any budget, adding to your history <br />
‣ Check your pie chart to see the net amount spent per budget; everytime you view the pie chart it is drawn with 1 out of the 10 color schemes included in my design, offering visibility and clarity on up-to-date data <br />
‣ View your entire, color-coded history log of <i>how much</i>, <i>why</i>, and <i>when</i> money was spent <br />
‣ View your transaction history within the past week on a bar graph, detailing how much you spent on a particular day <br />
&nbsp;&nbsp;&nbsp;&nbsp;– The graph also details the average amount spent per day for the past week <br />
‣ Manage multiple budgets at once <br />
‣ Undo an item in your history or delete your entire history, reverting your balance to its original value <br />
‣ Rename and delete budgets <br />

# Design
‣ CoreData allows for pertinent information to be stored regardless of whether or not the app is running <br />
‣ Designed a class that efficiently populates the x and y axes of the line graph <br />
‣ Constructed a dictionary that maps the current date to the total amount spent on that particular day <br />
‣ Buttons enable and disable dynamically based on the validity of input: <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Balance must be between $0 and $1,000,000 <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Spend button only enables when your balance is enough based on current input <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Renaming actions require the new name to be unique <br />
‣ History of transactions records the date of transaction along with a corresponding color: <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Red for money spent <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Green for money added <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Deleting history essentially reverts the transaction and restores your balance <br />
‣ Creating names will add (a number) if the name already exists: <br />
&nbsp;&nbsp;&nbsp;&nbsp;– I.E. if "Mall" is already a budget name, naming new "Mall" budgets results in "Mall (1)", "Mall (2)", etc. <br />
‣ Number Formatter: <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Used a regular expression to ensure that user inputs cannot exceed past 2 decimal places <br />
&nbsp;&nbsp;&nbsp;&nbsp;– Dollar amounts include comma separators and a $ sign in the front <br />
‣ Programmatically utilized alerts to record user input <br />
‣ List of budgets and each budget's history is displayed using a UITableview <br />
‣ Used IBOutlets to programmatically interact with user interface elements <br />
‣ Defined an IBAction function that corrects button-enabling every time the user types or deletes a character <br /> 

# Screenshots
![alt tag](http://i.imgur.com/cJVPu76.png)
![alt tag](http://imgur.com/M2d7THz.png)
![alt tag](http://imgur.com/qsUkzVA.png)
![alt tag](http://imgur.com/O6WP0WL.png)
![alt tag](http://imgur.com/yvlPxXa.png)
![alt tag](http://imgur.com/kwEcWHS.png)
![alt tag](http://imgur.com/5VYhOhU.png)
![alt tag](http://imgur.com/fWGAeh9.png)
![alt tag](http://imgur.com/3SLP821.png)
