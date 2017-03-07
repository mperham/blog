---
author: Mike Perham
categories:
- Software
- Uncategorized
date: 2014-05-27T00:00:00Z
title: The Reconciliation Step
url: /2014/05/27/the-reconciliation-step/
---

A lot of people ask me "How can I guarantee that a batch of jobs finished successfully?" Here's the sad fact: **you can't**. 99% of the time things go perfectly but there will always be some small percentage that fail for a myriad of reasons: hardware failure, software bug, thunderstorms in the cloud.  
<!--more-->

And this is true of business processes in general! Any type of asynchronous processing means you can never be sure of the outcome unless you also have a verification step: I call this step **reconciliation** and here's the dirty secret: **anything critical to the operation of your business requires reconciliation**. The entire Accounting industry is reconciliation: they verify via double-entry bookkeeping that a business's accounts payable and accounts receivable add up because **MONEY**.

If you have a business process using async processing like Sidekiq, chances are you need to reconcile the output of that process. Typically you'll write jobs which process some records in a database and then a cron job which runs daily to look for "strange" records. In the case of an e-commerce vendor like [The Clymb][1], we have areas in our administration tool which look for lingering orders which haven't pushed to the warehouse, reconcile our merchant credit card charges with our bank statements and many other checks. Some of these are automated tools that send email if they detect anything odd, others are manual tools designed to be run by people.

Reconciliation is the cost of doing business in an imperfect world and part of any executive's job is to ensure their team has put in place necessary reconciliation steps to verify critical operations. What does your business reconcile? How do you do it?

 [1]: http://theclymb.com/invite-from/mperham
