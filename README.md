# Pocket-Change
IOS App that helps users manage their personal expenses and log their day-to-day transactions | Developed with Swift

# Features
• Create a budget with a name and starting balance <br />
• Withdraw or deposit money from the corresponding budget <br />
• Manage multiple budgets at once <br />
• View your entire, color-coded history log of how much money was spent and why it was spent <br />
• Delete one or all items of your transaction history <br />
• Rename and delete budgets <br />

# Algorithms
• CoreData allows for pertinent information to be stored regardless of whether or not the app is running <br />
• Buttons enable and disable dynamically based on the validity of input <br />
  – Balance must be between $0 and $1,000,000 <br />
  – Withdraw button only enables when your balance is enough based on current input <br />
  – Renaming actions require the new name to be unique <br />
• History of transactions have a corresponding color: <br />
  – Red for money spent <br />
  – Green for money deposited <br />
• Creating names will add (a number) if the name already exists: <br />
  – I.E. if "Mall" is already a budget name, naming a new one "Mall" automatically results in "Mall (1)", etc. <br />
