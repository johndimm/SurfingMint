# Intuit Mint:  finding trends in discretionary spending 

This little project is an experimental reporting tool for Mint that is designed to help find trends in discretionary spending. 

Here's a video demo.

[![Surfing Mint?](https://img.youtube.com/vi/Hq44CdZdyr4/0.jpg)](https://www.youtube.com/watch?v=Hq44CdZdyr4)


First, a bit of background.  I started using Mint in 2009 because it solves the update problem.  You give Mint all your account passwords, so yes it takes a lot of trust, but then you just forget about it.   It automatically downloads transactions from your bank and other accounts and aggregates them into a single database with no expiration date. 

It also attempts to categorize all your expenses.  There are mistakes of course, but in general it works pretty well.   

So now I have a decade where all our financial transactions have been logged and categorized.   Maybe now I can figure out why we keep spending so much money.   

In the Trends tab, Mint has a report on Spending by Category.  By default, it shows everything.   You can restrict the data for the chart in various ways.  By selecting one or more categories to show, or selecting accounts, or time span.  Pick this month.   

The chart is interactive.  Pick Shopping, then here’s clothing.  Is this a lot?  Here are the transactions.   I don't know.  Compare to last month.  Much smaller.  Let’s look at the trend for this category.  Type “clothing” and select all time.  Peaks in December… hmmm.  Oh, obviously, Christmas.  I knew we tended to buy new clothes at Christmas time, but I didn’t realize how much. 

This interface is nice as far as it goes.  The problem I have is here, where you select a category.   I don’t want to select a category to show, I want to remove some categories. Why?  I want to separate discretionary and mandatory spending.  Mandatory spending is rent, mortgage, loans, bills, insurance premiums, utilities, and some other unavoidable expenses.  The things that are hard to change.  You have to switch jobs or move.  They are boring, usually the same from month to month.  Most of them are on autopay anyway.   

If we set them aside, the rest will be clearer.   Because I’m interested in the other categories, the things under our daily control, things we actually decide buy, sometimes with very little thought.  Discretionary Spending. 

Here’s a list of the Mint categories I had to set aside for my own data.  What I want here is just a None option in the dropdown, or a checkbox list of categories like the one for accounts.  If Mint had that feature, I would not have bothered to do this work. 

But, I did, and here’s my experimental interface.  You can look at just discretionary spending, or just mandatory spending, or both.  In discretionary spending, for this month, you see most the big categories: groceries, shopping, clothing, and restaurants.  The fifth big category is usually Cash & ATM, but we got by without much cash in April.  The big categories make up almost 3/4 of this spending. 

This interface lets you move easily from month to month.  You can use these buttons, or the arrow keys on your keyboard, to go next and previous.  Or you can jump to a random location using this timeline ribbon. 

On the right, we have the detailed transactions behind each aggregate amount. There's no popup, no need to lose your context in an effort to understand it.  You can see the graph and the detail behind it on the same page.  It’s just there. 

The stacked barchart in the middle gives you some information missing from the pie chart.  The problem with pie charts is that although they do a good job of showing the distribution in percentages of a whole, they can't tell you anything about the whole itself.  All pie charts look alike.  This bar in the middle complements the pie chart by showing the absolute dollar value in each category.  When it’s tall, we’re spending a lot of money.  It prevents misunderstanding when a smaller expense is shown as a larger slice of pie because overall spending is down. 

Finally, you already saw that you can use the left and right arrow keys to go previous or next through the months.   The up/down keys are also hooked up and they take you to different categories. So you can browse the 68 * 109 = 7,412 pages without a mouse.

Let’s take a look at some recent months.  April had 2 birthdays, so there was a lot of spending on clothes.  That’s the way it works.  In March, almost nothing for clothing, but a big chunk on a plane ticket.  Overall spending was lower than in April.  In February, there was no plane ticket, and no real clothing purchases, but the other top 5 discretionary spending categories are well represented.  In January, another plane ticket.  And back in December, a big month for this kind of spending, we see clothing back up at 19% and the top five back to 3/4 of spending.   

So each month has a very different look to it, and it all depends on our behavior.  The idea here is something like the dieting concept of writing down everything you eat.  Just being aware of what you are eating can have a positive effect on your eating behavior.  But this is so much easier.  With no effort on my part, I can see exactly how we are prioritizing our spending.  And knowledge is the first step to changing behavior. 

OK, that’s it.   

The code is available on GitHub, but I have not set it up as an online tool because who would trust my random website with their financial data?  If you can work with React and SQL, feel free to grab the code.  It’s lightweight, only a week’s work, and it’s not hard to deploy.  I’m running it on a Mac Air 2012 with 4 Gig.  If you are not a developer, you will have to hope somebody from Intuit sees this video and decides to implement the feature.  In the meantime, I have what I’ve always wanted for managing my personal finances. 
