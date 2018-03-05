---
title: Automatic Saving Of Invalid Resources in Rails While Maintaining a Clean RESTful Interface
permalink: 2008/06/09/automatic-saving-of-invalid-resources-in-rails-while-maintaining-a-clean-restful-interface
published_at: 2008-06-09 13:35:00 +0000
---

or, **How To Change Your World In One Line Of Code**

One of the cool things that we're doing at the AMC is building a large collection of loosely coupled Rails applications that communicate using REST. This is slightly unusual, as rails is predominantly used to build single apps that operate in isolation. In our experiences, we've picked up a number of tricks that we'd like to share. Here's the first, on how a single this single line of code has saved us weeks of time and effort. Here's the line in question:

```
if @bank_transaction.save && @bank_transaction.valid?
```

Read on to find out how this helps!

## RESTful Resources

This line is part of a new Rails app we're developing to centrally handle all online payments for our software systems at the AMC. In this payments application, we expose two key resources over REST: (1) line items, which the other apps create with the details of the items to purchase, and (2) bank transactions, which are passed line item IDs and credit card details for the purchase.

Naturally, the models behind these resources have a bunch of validation rules that ensure certain conditions are met before they can be saved successfully. If any of these requirements are not met, then the model fails to save and the error hash is returned to the client app.

For most resources, these error hashes are returned in the usual Rails-like way. Let's look at how `LineItemsController` does it:

```
class LineItemsController < ApplicationController
  # POST /line_items.xml
  def create
    @line_item = LineItem.new params[:line_item]
    respond_to do |format|
      if @line_item.save
        format.xml { render :xml => @line_item, :status => :created, :location => @line_item }
      else
        format.xml { render :xml => @line_item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
```

To paraphrase: if the items save successfully, return success and the line item in XML, otherwise return the error hash. Nice and predictable, nothing exciting here.

## Saving Invalid Resources

One of the resources in the payments app is different. These are the @BankTransactions@, which are about as "mission critical" as we get. Let's talk about the successful case first: during the creation of the `BankTransaction` model, if all the validations have passed, a before\_create callback is triggered that will talk to the bank (using ActiveMerchant, of course) and ask to make the transaction there. If this succeeds, the model is saved to the database and an XML representation of the saved model is passed back to the client application with a success code.

However, if the transaction with the bank fails, this is still information we care about. A failed transaction could be an indication of a larger problem, and also needs to be recorded for customer service purposes. It makes sense to save every failed transaction as well as every successful one. To this end, the callback that communicates with the bank always returns true, which allows the save continue, and records for both successful and unsuccessful transactions to be kept in the database.

_(Another approach to this problem would be to create a separate @TransactionLog@ model to store the transaction data, but this approach requires extra work. Having the `BankTransactions` save every time is essentially free. Excellent.)_

## Keeping the REST API Simple

While the payments app is saving unsuccessful transactions, the client apps do not want to keep these records around: all they care about is if a transaction is successful or not. The easiest way to make it simple for the clients is to make the creation of a bank transaction resource behave the same way as creating any other resource over REST in rails. This means that if a transaction with the bank fails, then it should _appear_ to the clients as if the save also failed.

This will require the controller to generate an errors hash if the transaction fails. This means that the model should be invalid at this point. Given that we save to the database even for failed transactions, the model should therefore be invalid after the save:

```
class BankTransaction < ActiveRecord::Base
  validate :must_be_successful_if_saved
  before_create :transact

  private

  def transact
    # talk to the bank here, and set self.success to true or false pending the results
    # return true to make sure a save always occurs
    true
  end

  def must_be_successful_if_saved
    errors.add_to_base("failed to transact successfully with the bank") if !new_record? && !success?
  end
end
```

And then, in the `BankTransactionsController`, that one magic line:

```
class BankTransactionsController < ApplicationController
  # POST /bank_transactions.xml
  def create
    @bank_transaction = BankTransaction.new params[:bank_transaction]
    respond_to do |format|
      if @bank_transaction.save && @bank_transaction.valid?
        format.xml { render :xml => @bank_transaction, :status => :created, :location => @bank_transaction }
      else
        format.xml { render :xml => @bank_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
end
```

Unlike the standard behaviour shown in the `LineItemsController` above, we only return a successfully created model if the save is successful AND it is still valid afterwards. A saved model for a failed transaction with the bank will be invalid at this point, so it will return the errors hash. To the client app, this looks like the same resource it tried to create initially, and so it can proceed as usual to display the errors, ask for corrections if necessary, and try to save again. In the background, the payments app has saved every failed transaction for safe keeping.

