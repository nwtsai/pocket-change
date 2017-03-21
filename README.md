# Pocket Change
iOS App made from scratch that helps users visualize their personal expenses and log their day-to-day transactions

# Features
‣ View your entire, color-coded history log of <i>how much</i>, <i>why</i>, <i>where</i>, and <i>when</i> money was spent <br />
‣ Integrated the application with the Google Maps API to visualize where money was spent when the user travels <br />
‣ When a user taps on a transaction, the map animates and centers on the location of where the transaction happened <br /> 
‣ Create a budget with a name and starting balance <br />
‣ Spend or add money to any budget, adding to your history <br />
‣ Check your pie chart to see the net amount spent per budget; everytime you view the pie chart it is drawn with 1 out of the 10 color schemes included in my design, offering visibility and clarity on up-to-date data <br />
‣ View your transaction history within a specified time interval (past week, month, or year) on a bar graph <br />
&nbsp;&nbsp;&nbsp;&nbsp;– A horizontal line details the average amount spent per day for the specified time interval <br />
&nbsp;&nbsp;&nbsp;&nbsp;– The user can customize each budget's bar graph with 11 different color schemes <br />
‣ Manage multiple budgets at once <br />
‣ Undoing an item in your history or deleting your entire history reverts your balance to its original value <br />
‣ Rename and delete budgets <br />

# Design
‣ Implemented CoreData to store pertinent information unique to the individual budgets <br />
‣ Designed a class that efficiently populates the x and y axes of the bar graphs <br />
‣ Constructed a backend design that stores the location information of each transaction <br />
‣ Developed an efficient method for retrieving data by relying on the fast lookup of Swift dictionaries when dealing with transaction history <br />
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
![alt tag](http://i.imgur.com/aJq4TRP.jpg)
![alt tag](http://i.imgur.com/hmijcF0.jpg)
![alt tag](http://i.imgur.com/XvlLNAy.png)
![alt tag](http://i.imgur.com/SpD5mU6.jpg)
![alt tag](http://i.imgur.com/h2LF60Y.jpg)
![alt tag](http://i.imgur.com/WzapKJJ.png)
![alt tag](http://i.imgur.com/nUnKxzp.jpg)
![alt tag](http://i.imgur.com/xU8B3eQ.png)
![alt tag](http://i.imgur.com/1cCDaJq.png)

