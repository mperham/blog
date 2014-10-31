---
title: Using Apache DS, Part 2
author: Mike Perham
layout: post
permalink: /2007/09/28/using-apache-ds-part-2/
keywords:
  - apacheds, ldap, ldif
categories:
  - Software
---
Now that we have the LDAP server running, we need to be able to CRUD the data within the LDAP server. ApacheDS does not have an integrated GUI but it does have a companion tool, [Apache Directory Studio][1], which can connect to the server and edit its data.

1.  Download and install Studio. Start it. It&#8217;s Eclipse-based so Java developers should be familiar with its GUI.
2.  Go to LDAP | New Connection&#8230; and create a connection: 
    *   Hostname: localhost
    *   Port: 10389
    *   Bind DN: uid=admin,ou=system
    *   Bind password: secret
    
    Leave everything else as default. Click OK.</li> 
    *   You should now see Studio display a tree-structure on the left. This is the content in your LDAP server.  
        [<img src="http://www.mikeperham.com/wp-content/uploads/2007/09/adstudio.png" style="margin-left: -50px" alt="Apache Directory Studio" />][2]
    *   Now you&#8217;ll want to import the data specific to your organization or product. First you need to create a parition which holds your data. In the screenshot above, &#8220;dc=example,dc=com&#8221; is a partition for example.com. [Creating a partition][3] is not as easy as it could be but basically involves cutting and pasting a block of XML and changing it in 3 spots to fit your needs.
    *   With our own partition we can import our data. You can use Studio to create the data but it&#8217;s a manual process. Instead you should create an [LDIF][4] file which contains your data. All you need to do is create a DS_HOME/ldif directory and place your LDIF files in this directory. ApacheDS will load the LDIF files upon startup. Do note that LDIF is not an easy format to work with. It&#8217;s another example where you will want to schedule some time to play with it in order to understand its quirks and foibles. Here&#8217;s a simple [Fiveruns LDIF datafile][5] which creates an organizational unit and a user within a &#8220;FiveRuns&#8221; partition.</ol> 
    That&#8217;s all for now. Next we&#8217;ll access this data from Ruby!

 [1]: http://directory.apache.org/studio/
 [2]: http://www.mikeperham.com/wp-content/uploads/2007/09/adstudio.png "Apache Directory Studio"
 [3]: http://directory.apache.org/apacheds/1.0/14-basic-configuration-tasks.html#1.4.Basicconfigurationtasks-Addingyourownpartitionresp.suffix
 [4]: http://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format
 [5]: http://www.mikeperham.com/wp-content/uploads/2007/09/fiverunsldif "Fiveruns LDIF data"