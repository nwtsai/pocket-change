# Pocket-Change
IOS App that helps users manage their personal expenses and log their day-to-day transactions | Developed with Swift

# Features
This App allows you to:
• Create a budget with a name and starting balance
• Withdraw or deposit money from the corresponding budget
• Manage multiple budgets at once
• View your entire, color-coded history log of how much money was spent and why it was spent
• Delete one or all items of your transaction history
• Rename and delete budgets

# Algorithms
• CoreData allows for pertinent information to be stored regardless of whether or not the app is running
• Buttons enable and disable dynamically based on the validity of input
  – Balance must be between $0 and $1,000,000
  – Withdraw button only enables when your balance is enough based on current input
  – Renaming actions require the new name to be unique
• History of transactions have a corresponding color:
  – Red for money spent
  – Green for money deposited
• Creating names will add (a number) if the name already exists:
  – I.E. if "Mall" is already a budget name, naming a new one "Mall" automatically results in "Mall (1)", etc.
