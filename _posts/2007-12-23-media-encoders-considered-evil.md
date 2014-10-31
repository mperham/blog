---
title: Media Encoders Considered Evil
author: Mike Perham
layout: post
permalink: /2007/12/23/media-encoders-considered-evil/
keywords:
  - vlc, media, ffmpeg, mp3, encode
categories:
  - Software
---
I&#8217;m always re-amazed (about once per year) at how crappy the open source media encoding applications are.  I&#8217;m talking about LAME, VLC, ffmpeg, et al.  I&#8217;m sure their code is sparkling clean and their compression tight but their usability is a disaster.  There is an entire cottage industry around putting simplification layers on top of these libraries in order to make them usable by mere humans.

I bought a new Sansa Clip mp3 this weekend and the thing is awesome: super tiny, FM receiver, voice and FM recording, shows up as a USB drive and works with my MacBook.  So I recorded some [KJAZZ][1] (the best Jazz radio station in the US and the thing I miss most about LA) and the Clip saved it as a WAV file internally.

So now I want to convert this WAV file into an MP3.  How do you do it?  Well, in VLC you go through a complex wizard which offers way too many unexplained choices.  &#8220;Encapsulation format&#8221;?  Huh?  I&#8217;ve got plenty of Internet street cred and I&#8217;ve never even heard of this term.

**Make a few common use-cases easy!!!**  Converting audio from XXX to MP3 is a very standard need.  You don&#8217;t need to dumb down the tool but provide a wrapper script &#8220;tomp3 <in> <out>&#8221; which sets all the command line switches automatically.  The script covers a major use-case AND it provides a great example for customization if the user wants better control &#8211; e.g. a user would know to just edit the file and change 128 to 192 if you want higher-quality MP3s.

Providing a few samples of how to perform typical encoding needs would go a long way towards making these tools friendlier for technical users who don&#8217;t want to spend hours googling and parsing man pages.

 [1]: http://www.jazzandblues.org/