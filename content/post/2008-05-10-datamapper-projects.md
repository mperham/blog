---
author: Mike Perham
categories:
- Ruby
date: 2008-05-10T00:00:00Z
title: DataMapper projects
url: /2008/05/10/datamapper-projects/
---

As someone who was pretty closely involved in an OSS project that exploded into hundreds of little subprojects, I have to say I'm discouraged to see DataMapper and Merb starting to go down that same road.

    
    drwxr-xr-x  3 102 May 10 15:16 adapters
    drwxr-xr-x  8 272 May 10 15:16 dm-aggregates
    drwxr-xr-x  8 272 May 10 15:16 dm-ar-finders
    drwxr-xr-x  9 306 May 10 15:16 dm-cli
    drwxr-xr-x  7 238 May 10 15:16 dm-is-tree
    drwxr-xr-x  9 306 May 10 15:16 dm-migrations
    drwxr-xr-x  8 272 May 10 15:16 dm-serializer
    drwxr-xr-x  8 272 May 10 15:16 dm-timestamps
    drwxr-xr-x  8 272 May 10 15:16 dm-types
    drwxr-xr-x  8 272 May 10 15:16 dm-validations
    drwxr-xr-x  9 306 May 10 15:16 merb_datamapper
    
    

This looks like the Apache Maven project and, believe me, that way leads to madness. There's a lot of be said for a single, integrated project.
