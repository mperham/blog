---
title: "My Coolest Code"
date: 2020-05-04T13:26:58-07:00
publishdate: 2020-05-04
lastmod: 2020-05-04
tags: []
---

What's the coolest code you've written, for your own definition of cool?

## EDI: the Worst Document Format?

From 2003-2006 I worked at a startup building enterprise software for the health care space.
We were building a system which allowed doctors offices to
submit real-time transactions over the Internet, to migrate offices away from phone, fax or mail.
Our first step was allowing real-time inquiry for insurance eligibility and benefits of a patient.
Each doctor's office runs an EMR ("Electronic Medical Records") system.
When John Doe walks into his doctor's office, they call his insurance company to
determine co-pays, etc. With our system, the EMR could do this automatically in seconds.

The industry has an standard format for this request, known as [X12 270](https://www.1edisource.com/resources/edi-transactions-sets/edi-270/).
It looks like this:

```
ISA*01*0000000000*01*0000000000*ZZ*ABCDEFGHIJKLMNO*ZZ*123456789012345*101127*1719*U*00400*000003438*0*P*>
GS*HS*4405197800*999999999*20120117*1719*1421*X*004010VICS
ST*270*1234
BHT*0022*13*1*20010820*1330
HL*1**20*1
NM1*PR*2******PI*123456789
HL*2*1*21*1
NM1*1P*2******SV*987654321
HL*3*2*22*0
NM1*IL*1*DOE*JANE****MI*345678901
EQ*30**FAM
SE*10*1234
GE*1*1421
IEA*1*000006768
```

The corresponding response is known as [X12 271](https://www.1edisource.com/resources/edi-transactions-sets/edi-271/).
The doctor's EMR would submit a 270 document to us, we'd need to
parse it, pass the data to the BigHealthInsuranceCo, get the response
back and convert that response into a 271 document to return to
the EMR.

So a quick rundown:

* [EDI](https://en.wikipedia.org/wiki/Electronic_data_interchange) - a generic but incomprehensible document format
* [X12](https://en.wikipedia.org/wiki/ASC_X12) - specific set of industry-standard documents using EDI
* [270](https://en.wikipedia.org/wiki/X12_Document_List#Insurance/Health_Series_\(INS\)) - insurance benefit inquiry document

Oh, EDI documents are also called transactions so, yay confusion!
I'm going to stick to calling them documents.

## The Problem

The core difficulty we needed to solve:
**how the hell do we parse the above gobblygook into an object format we can easily CRUD?**
Keep in mind, the 270 document is about the simplest document format -- it gets way, way more complex -- so using regular expressions to parse were out of the question.

But "parse" is the key word here.

I realized we needed to go up a level of abstraction and get a machine-readable description of each EDI document format so we could build a parser.
This is when I discovered [SEF descriptors](https://www.edidev.com/eval_SefFile.html).
Each document type (270, 271, etc) has an associated SEF descriptor which describes the specific EDI document format.
The essence of what I'm so proud of is this:

    a JavaCC grammar for parsing SEF files and generating a JavaBeans object model so we can parse specific EDI documents, manipulate the JavaBeans and emit an updated, well-formed document

I got something bare bones working after a month or so; soon we had full support for 270, 271, 835, 837p, 837i and other health related transactions.

## The Solution

[Here's the code!](https://github.com/mperham/edistuff)
Keep in mind that all of this code and data is almost 20 years old, I put it on GitHub purely for my own historical interest.

I read the SEF document format standard in [sef16.pdf](https://github.com/mperham/edistuff/blob/master/src/parser/sef16.pdf)
and built a [JavaCC grammar](https://github.com/mperham/edistuff/blob/master/src/parser/sef.jj) for it.

Here's an old [270 SEF](https://github.com/mperham/edistuff/blob/master/src/parser/270.sef).
Once I had the grammar, I could use JavaCC to [parse the SEF](https://github.com/mperham/edistuff/tree/master/src/java/com/webify/shared/edi/parser/sef) for each document type and emit [Java code](https://github.com/mperham/edistuff/tree/master/src/java/com/webify/shared/edi/model/hipaa270/beans) which knew how to parse an EDI 270 InputStream into a set of Java beans.
With a set of JavaBeans which described the document, the sky was the
limit -- we could write any business logic the customer needed.

## The Conclusion

So instead of maintaining a massive set of horrid regexps, I maintained the SEF grammar and JavaBeans generator.
If we needed a new feature for the various document types, I could implement it and regenerate the JavaBeans,
giving all document types that new feature.
If we needed to support a new X12 document type, I just grabbed the SEF for it and generated the associated beans.
Typically it would take me hours rather than months.

Behold, the power of an abstraction layer. That's pretty cool.

## Postscript

I haven't written Java in 15 years.  I saw Ruby on Rails in 2005 and fell in love with Ruby.

These days I believe X12 has been superceded by the [HL7 standard](https://en.wikipedia.org/wiki/Health_Level_7) which uses XML and therefore is easy to parse.
EDI should be relegated to the dustbin of legacy formats ASAP.
