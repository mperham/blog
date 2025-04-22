---
author: Mike Perham
categories:
- Ruby
date: 2009-03-10T00:00:00Z
title: SystemTimer 1.1 crash
url: /2009/03/10/systemtimer-11-crash/
---

We're trying to use SystemTimer 1.1 on 64-bit Ubuntu and find that it crashes. An hour's worth of investigation led to this fix:

```diff
--- a/ext/system_timer/system_timer_native.c
+++ b/ext/system_timer/system_timer_native.c
@@ -25,7 +25,7 @@ static void install_ruby_sigalrm_handler(VALUE);
 static void restore_original_ruby_sigalrm_handler(VALUE);
 static void restore_original_sigalrm_mask_when_blocked();
 static void restore_original_timer_interval();
-static void set_itimerval_with_minimum_1s_interval(struct itimerval *, int);
+static void set_itimerval_with_minimum_1s_interval(struct itimerval *, VALUE);
 static void set_itimerval(struct itimerval *, int);
 static void restore_sigalrm_mask(sigset_t *previous_mask);
 static void log_debug(char*, ...);
@@ -262,7 +262,7 @@ static void init_sigalarm_mask()
 }

 static void set_itimerval_with_minimum_1s_interval(struct itimerval *value,
-                                                   int seconds) {
+                                                   VALUE seconds) {

     int sanitized_second_interval;
```

I hope this helps someone else with the same problem. The author has been notified.
