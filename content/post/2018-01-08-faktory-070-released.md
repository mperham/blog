+++
date = "2018-01-08T10:53:00-08:00"
title = "Faktory 0.7.0 Released"
+++

Faktory is my brand-new background job system for every programming language.
If you want to learn more, see [the intro](http://www.mikeperham.com/2017/10/24/introducing-faktory/).
It's been three months since the initial launch in October and I've heard of several successful rollouts to production.
If you were reluctant to try out Faktory before, it's time to start looking into it because
the biggest release of Faktory yet is now available to all.
November and December saw lots of changes and improvements; here's a recap.

<img style="float: right; padding: 3px" src="http://www.mikeperham.com/images/faktory-logo.png" alt="logo"/>


## Job Priorities

**Jobs can now be prioritized from 1-9 within a queue!**
The initial release of Faktory was focused on replicating Sidekiq's existing functionality but Faktory's different architecture allows us to implement features that were impossible in Sidekiq.
Many, many people have asked for a simple job prioritization scheme but I've never implemented it in Sidekiq because of the high runtime cost.
But since we now control the low-level storage details in Faktory, we can minimize those costs!
Want something to go to the front of a queue, give it a high priority like 9.
Want it to drop to the back?
Simple as:

```
{ "jobtype":"MyJob","args":[1,2,3],"queue":"encoding","priority":1 }
```

@andrewstucki did the hard work to design an efficient implementation using a data structure I'd never heard of: the [Brodal queue](https://en.wikipedia.org/wiki/Brodal_queue).
Nice to see some real Computer Science data structure theory paying off here!

## Reliability

Recovered jobs (jobs which kill their worker process, aka poison pills) now use the retry process.
This ensures that recovered jobs are exponentially backed off and won't retry every 30 minutes forever as before.

Faktory now automatically creates backups every hour when in production mode, keeping 24.
This gives you a full day of backups to recover in case of disaster.

Note #1: remember that Faktory is a queue system and queues are normally empty.
It is typical for Faktory's dataset to be less than 10MB in size unless you are scheduling or retrying lots of jobs.

Note #2: background jobs will run **at least** once.
Restoring a backup is one way to see duplicate job execution.
You should always strive for [idempotency](https://github.com/mperham/sidekiq/wiki/Best-Practices#2-make-your-job-idempotent-and-transactional) when writing jobs.

## Newsletter

I've created a newsletter for those who want the latest news ASAP.
Subscribers will get Faktory-related posts like this a day early.
You can subscribe right here or on the [Faktory home page](http://contribsys.com/faktory/).

<!-- Begin MailChimp Signup Form -->
<link href="//cdn-images.mailchimp.com/embedcode/horizontal-slim-10_7.css" rel="stylesheet" type="text/css">
<style type="text/css">
	#mc_embed_signup{background:#fff; clear:left; font:14px Helvetica,Arial,sans-serif; width:100%;}
</style>
<div id="mc_embed_signup">
<form action="https://contribsys.us17.list-manage.com/subscribe/post?u=c04c3b4f7f54b0a65d156c7e4&amp;id=e3d75d426c" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate>
    <div id="mc_embed_signup_scroll">
	<label for="mce-EMAIL">Subscribe to Faktory Insiders</label>
	<input type="email" value="" name="EMAIL" class="email" id="mce-EMAIL" placeholder="email address" required>
    <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
    <div style="position: absolute; left: -5000px;" aria-hidden="true"><input type="text" name="b_c04c3b4f7f54b0a65d156c7e4_e3d75d426c" tabindex="-1" value=""></div>
    <div class="clear"><input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" class="button"></div>
    </div>
</form>
</div>
<!--End mc_embed_signup-->

## Faktory-as-a-Service

Two different companies have sprung up, aimed at providing Faktory as a service.
If you have an application on Heroku, you can start using Faktory in minutes!
Check out [Ackfoundry](https://www.ackfoundry.com/) and [Konglomerate](http://konglomerate.io/) for the latest details.

## Worker Packages

Several Faktory [worker packages](https://github.com/contribsys/faktory/wiki/Related-Projects) are seeing solid support and regular improvements.
Take a look at the Rust, Elixir, Python and Node packages for example.

Don't see one for your language?
Jump into the [chatroom](https://gitter.im/contribsys/faktory) and ask!

## Security

Faktory's security design has been one of the toughest engineering problems to solve.
By default we want both an easy development experience and a secure production deployment.
To that end, we've made several major [security policy](https://github.com/contribsys/faktory/wiki/Security) changes:

### Faktory will not terminate TLS

Since most deployments these days are using Docker or another container, we've decided the Faktory server will not terminate TLS.
Instead your network architecture should provide any necessary TLS frontend using haproxy, spiped, stunnel, nginx, etc.

Faktory clients will all continue to support TLS by including "tls" in the URL scheme, e.g. `tcp+tls://faktory.example.com:7419`.

### Passwords are mandatory in production

Faktory is one of the few pieces of infrastructure which bake in the idea of "environment" (production and development are the two choices).
Going forward, a production server must be started with a FAKTORY\_PASSWORD environment variable in order to authenticate all connections.

It's easy to include the password in the connection URL: `tcp+tls://:mypassword123@faktory.example.com:7419`.

### CSRF protection

@vosmith was nice enough to provide a pull request adding CSRF protection to the Web UI.
CSRF protection prevents a malicious webpage from using your browser to submit a form request, e.g. to clear a queue.
Further security improvements to the Web UI are always welcome.

## Conclusion

That's it for now!
[Jump into the chatroom](https://gitter.im/contribsys/faktory) if you have questons or concerns.
And as I said before, I've heard of several successful rollouts to production.
If you were reluctant to try out Faktory before, it's time to start looking into it!
See my [Getting Started](http://www.mikeperham.com/2017/11/13/getting-started-with-faktory/) guide.

