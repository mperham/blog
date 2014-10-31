---
title: Detecting Duplicate Images with Phashion
author: Mike Perham
layout: post
permalink: /2010/05/21/detecting-duplicate-images-with-phashion/
categories:
  - Ruby
  - Software
---
Recently I was given a ticket to implement a &#8220;near-duplicate&#8221; image detector. Look at these three images:  
  
The original image files have different bytesizes and different sizes but they show essentially the same thing. This is what we call a &#8220;near-duplicate&#8221; and the problem was that when displaying an automatically generated image gallery for a given subject, we were sometimes showing duplicate images due to slight differences in the images.

Obviously we can&#8217;t use something like an MD5 or SHA1 fingerprint &#8211; we have to create a fingerprint based on the content of the image, not the exact bytes. This is what the [pHash library][1] does. A &#8220;perceptual hash&#8221; is a 64-bit value based on the discrete cosine transform of the image&#8217;s frequency spectrum data. Similar images will have hashes that are close in terms of [Hamming distance][2]. That is, a binary hash value of 1000 is closer to 0000 than 0011 because it only has one bit different whereas the latter value has two bits different. The duplicate threshold defines how many bits must be different between two hashes for the two associated images to be considered different images. Our testing showed that 15 bits is a good value to start with, it detected all duplicates with a minimum of false positives.

[Phashion][3] is my new Ruby wrapper for the pHash library and wraps just enough of the pHash API to implement the described functionality. Here&#8217;s the test in the test suite which verifies that Phashion considers the images to be duplicates:

<pre lang="ruby">def assert_duplicate(a, b)
    assert a.duplicate?(b), "#{a.filename} not dupe of #{b.filename}"
  end
  def test_duplicate_detection
    files = %w(86x86-0a1e.jpeg 86x86-83d6.jpeg 86x86-a855.jpeg)
    images = files.map {|f| Phashion::Image.new("#{File.dirname(__FILE__) + '/../test/'}#{f}")}
    assert_duplicate images[0], images[1]
    assert_duplicate images[1], images[2]
    assert_duplicate images[0], images[2]
  end
</pre>

pHash does have much more functionality, including video and audio support and persistent MVP tree support for similarity searches based on previously processed files, but I have not wrapped any of those APIs. Try it out and let me know what you think!

 [1]: http://phash.org
 [2]: http://en.wikipedia.org/wiki/Hamming_distance
 [3]: http://github.com/mperham/phashion