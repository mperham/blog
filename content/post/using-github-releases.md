+++
title = "Building Linux Packages and using Github Releases"
date = 2018-10-10T13:31:27-07:00
+++

I'm preparing to launch [Faktory](https://github.com/contribsys/faktory) 0.9, a major overhaul to switch
from RocksDB to Redis as the storage engine.
The improvement in the development process is amazing.
But I need to finalize how I distribute Faktory releases, which brings
up the question:

{{< tweet 1050047444480753664 >}}

As of right now, that tweet poll shows 58% of people want a deb, 32% want a Docker image, 7% want an rpm and 3% are Linux hipsters that lovingly craft each network packet by hand.

## Building Packages

By removing RocksDB, a C++ dependency, we moved from a cgo build to a pure Go build.
The advantages of a pure Go build process are hard to overstate:

1. I can cross-compile Linux binaries on OSX
1. Since it doesn't use glibc and libcpp, I don't need to build distro-specific binaries
1. I don't need to use Vagrant or Docker to run Linux in order to build packages
1. I could narrow the package formats to only two, deb and rpm, and really I could get away with one.
DEB appears to have won the popularity contest and Debian distros seem to be the strong majority among my followers.

With these changes, Faktory's package build went from an hour of manually running various scripts to **four seconds**.
That's four seconds for a **full build**: cleaning, generating, cross compiling and building the deb/rpm files.

```
$ time make package
go generate github.com/contribsys/faktory/webui
Created package {:path=>"packaging/output/systemd/faktory_0.9.0-beta3_amd64.deb"}
Created package {:path=>"packaging/output/systemd/faktory-0.9.0-beta3.x86_64.rpm"}

real	0m4.218s
user	0m3.529s
sys	0m0.833s
```

There are only two requirements for these packages: 64-bit Linux and systemd.
No business is running 32-bit anymore for anything but edge case reasons.
systemd has been the Ubuntu default for ~4 years now so I'm ok with that for now.

The unsung hero in all of this build process is [the `fpm` gem](https://github.com/jordansissel/fpm/).
Jordan Sissel deserves our eternal praise for his work in making it easy to build Linux packages anywhere.
If I could license "FPM Pro" to pay him for his work, I would in a heartbeat.
In the meantime, my public thanks will have to be enough.


## Using GitHub Releases

Now that I can build these "universal" packages, how do I distribute them?
apt/yum repos are notoriously painful to setup and run.
Easiest quick solution that I know of is to use GitHub releases:
tag the code, generate the packages and then create a release.
Here's how I create a Faktory release:

```make
release: clean test package tag
  @echo Generating release notes
  ruby .github/notes.rb $(VERSION)
  @echo Releasing faktory $(VERSION)-$(ITERATION)
  hub release create v$(VERSION)-$(ITERATION) \
    -a packaging/output/systemd/$(NAME)_$(VERSION)-$(ITERATION)_amd64.deb \
    -a packaging/output/systemd/$(NAME)-$(VERSION)-$(ITERATION).x86_64.rpm \
    -F /tmp/release-notes.md -e -o
```

Note the Ruby script to generate the release notes automatically,
including changelog link and SHA256 sums for each file.
`brew install hub` to get GitHub's handy CLI tool.

To install that DEB:

```bash
curl -LO https://github.com/contribsys/faktory/releases/download/v0.9.0-beta3/faktory_0.9.0-beta3_amd64.deb
dpkg -i faktory_0.9.0-beta3_amd64.deb
```

## Conclusion

GitHub Releases work well enough for now.
They don't have the benefit of a full-blown package repo but they provide a stable download link for binaries and are far simpler to setup and use from my POV.
In reality, I would imagine most teams will fetch and install the package via Puppet/Chef/Ansible.
Hopefully as Faktory gets more popular, it will make its way into the official distro repos.
