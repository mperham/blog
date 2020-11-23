---
title: "Running Ruby on RISC-V"
date: 2020-11-21T16:18:34-08:00
publishdate: 2020-11-21
lastmod: 2020-11-21
tags: []
---

With the release of the new arm64 architecture M1 Macbooks, I started
wondering about x86 alternatives and came across [RISC-V](https://en.wikipedia.org/wiki/RISC-V).
RISC-V is an open source ISA (the set of instructions documented by a CPU) which does not cost anything to use.
Anyone can take the ISA, build a chip which implements the ISA and then
any software compiled for RISC-V will run on that chip. Several
generations of RISC ISAs were created at UC Berkeley in the 1980s; RISC-V denotes their fifth generation ISA.

I believe we'll see more and more low-end Linux devices powered by RISC-V chips from inexpensive Asian fabs.
Intel doesn't license x86_64 to other chipmakers AFAIK and it's simply too big and unwieldy for anyone to want to.
ARM's entire business model is licensing its ISA but requires a
major dollar investment, something which many smaller companies don't have.

One interesting possibility with RISC-V, as an open source ISA, is the
ability to add/remove [standard extensions](https://en.wikipedia.org/wiki/RISC-V#ISA_base_and_extensions) or even add your own custom instructions. Imagine a handful of
CPU instructions tuned to dynamic languages like Python or Ruby!
Companies like [SiFive](https://www.sifive.com) now offer the ability to custom design and
build your own SoC. Want a very small 32-bit chip with no floating point
math? No problem! Want a general purpose 64-bit desktop-class chip? No problem!

## The State of Software

Being so widely used and low level, C/C++ are always the first languages to move. The GCC and LLVM compilers both have
RISC-V support, typically they support the "RV64GC" ISA which stands for
"RISC-V 64-bit with G and C extensions". RV64GC is the most complex form of
RISC-V and
has all the instructions necessary to run basically any modern software; embedded
compilers targeting smaller chips will support smaller versions of RISC-V like "RV32G".
Golang supports RV64GC starting in the 1.15 release.

## Running RISC-V without RISC-V

I decided to take RISC-V for a test drive. The
first step of trying any new CPU is to run it in an emulator; after all
I don't actually own a RISC-V chip or machine!
QEMU is the open source gold standard for CPU emulation:

```
brew install qemu
```

QEMU comes with [RISC-V built-in](https://git.qemu.org/?p=qemu.git;a=tree;f=target/riscv;h=4d5374737a3e0c52f60c7cc69738e195d8ba8497;hb=refs/heads/master) so there's nothing else to be done
(click that link if you want to see how to emulate a CPU with 1000s of lines of C code).
You'll need to download a RISC-V native boot disk, I found instructions and a nice [Fedora
Developer 20200108 image](https://wiki.qemu.org/Documentation/Platforms/RISCV#Booting_64-bit_Fedora) here.
This developer image contains all the typical Linux developer tools, including GCC.
I followed those directions except note we are using the **Developer** image, not the
**Minimal** image. You log in with user:pwd "riscv:fedora_rocks!".

```
> curl -LO Fedora-Developer-Rawhide-20200108.n.0-fw_payload-uboot-qemu-virt-smode.elf
> curl -LO Fedora-Developer-Rawhide-20200108.n.0-sda.raw.xz
> unxz *.xz
> qemu-system-riscv64 \
   -nographic \
   -machine virt \
   -smp 4 \
   -m 2G \
   -kernel Fedora-Developer-Rawhide-*-fw_payload-uboot-qemu-virt-smode.elf \
   -bios none \
   -object rng-random,filename=/dev/urandom,id=rng0 \
   -device virtio-rng-device,rng=rng0 \
   -device virtio-blk-device,drive=hd0 \
   -drive file=Fedora-Developer-Rawhide-20200108.n.0-sda.raw,format=raw,id=hd0 \
   -device virtio-net-device,netdev=usernet \
   -netdev user,id=usernet,hostfwd=tcp::10000-:22
 ```

Soon I had a Fedora terminal prompt, this was easy so far!
*Alas, storm clouds approached...*

My plan was to start with the latest stable Ruby release. I downloaded the Ruby 2.7.2 source tarball, unpacked it and ran through the usual `./configure ; make` steps but it did not compile due to some C casting errors.
I recalled that Ruby 2.7 has been frozen for 1-2 years now; perhaps it was fixed in the latest version?
I downloaded Ruby 3.0.0-pre1 and ran the same steps.

🌈✨💪🏼 **It compiled!** 🥰✨🎉

Natively, Ruby 3.0 took 4 minutes to compile on my 2016 MBP.

```
x86_64-darwin19-fake.rb updated
make  240.65s user 35.12s system 98% cpu 4:40.59 total
```

Under emulation, it took 123 minutes to compile. I guess you could say there is a bit of
slowdown under emulation.

```
riscv64-linux-fake.rb updated
real	123m35.402s
user	93m56.389s
sys	29m31.974s
```

In the end, this was the result:

```
$ ./miniruby -e "puts RUBY_DESCRIPTION"
ruby 3.0.0preview1 (2020-09-25 master 0096d2b895) [riscv64-linux]
```

## What's the Point?

At a glance this doesn't look revolutionary.

I don't expect we'll see RISC-V processors in your next Windows or Mac
laptop but for companies building their own embedded hardware (e.g. hard
drive manufacturers) an Open ISA represents one less point of vendor lockin.
Now companies can go to the RISC-V ecosystem, say "I need 100,000 units
of a RV32G processor with max power draw of less than 1W" and many companies can bid for this
proposal. No IP licensing, no NDAs for hardware datasheets, just cash for chips based on an open standard.
