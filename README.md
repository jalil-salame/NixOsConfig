# My NixOs Config

Here to show other people how I over engineer things c:

You can look, probably don't use this, it might sporadically break

> [!Important]
> Although I am trying to make this config work on `nixos-23.05` it currently
> only works on `nixos-unstable` (at least the images built with
> nixos-generators). Your milage may vary.

## Build example configuration

This uses [`nixos-generators`](https://github.com/nix-community/nixos-generators)
so you can use any of the
[supported formats](https://github.com/nix-community/nixos-generators#supported-formats)

This for example builds a QEMU VM

```console
$ cd examples/simple-stable
$ nix build .#nixosConfigurations.simple.config.formats.vm
```

## Run example configuration

You need to enable `virtio-vga` (`virtio-gpu` may work for you but it didn't
for me). You could also do GPU pass through, but I only have a single GPU so
it's untested.


```console
$ QEMU_OPTS='-device virtio-vga' ./result
```
