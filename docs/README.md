[![Green Beret Logo](gberet-logo.png)](#)

---

[![Active Development](https://img.shields.io/badge/Maintenance%20Level-Actively%20Developed-brightgreen.svg)](#status-of-features)
[![Build](https://github.com/opengateware/arcade-gberet/actions/workflows/build-pocket.yml/badge.svg)](https://github.com/opengateware/arcade-gberet/actions/workflows/build-pocket.yml)
[![release](https://img.shields.io/github/release/opengateware/arcade-gberet.svg)](https://github.com/opengateware/arcade-gberet/releases)
[![license](https://img.shields.io/github/license/opengateware/arcade-gberet.svg?label=License&color=yellow)](#legal-notices)
[![issues](https://img.shields.io/github/issues/opengateware/arcade-gberet.svg?label=Issues&color=red)](https://github.com/opengateware/arcade-gberet/issues)
[![stars](https://img.shields.io/github/stars/opengateware/arcade-gberet.svg?label=Project%20Stars)](https://github.com/opengateware/arcade-gberet/stargazers)
[![discord](https://img.shields.io/discord/676418475635507210.svg?logo=discord&logoColor=white&label=Discord&color=5865F2)](https://chat.raetro.org)
[![Twitter Follow](https://img.shields.io/twitter/follow/marcusjordan?style=social)](https://twitter.com/marcusjordan)

## Konami [Green Beret] Compatible Gateware IP Core

This Implementation of a compatible Green Beret arcade hardware in HDL is the work of [MiSTer-X].

> This game is known in US as "Rush'n Attack".

## Overview

Green Beret is a sideways-scrolling action/platform game set during the Cold War, in which a US Special Forces Marine must infiltrate a Russian military base to save four POW's from being executed by firing squad.

Initially, the soldier is armed with only a combat knife, but by killing the certain enemy troops, players can obtain either a three-shot flamethrower, a four-shot RPG, or a three-pack of hand grenades.

## Technical specifications

- **Game ID:**      GX577
- **Main CPU:**     Zilog Z80 @ 3.72 MHz
- **Sound CPU:**    SN76489A @ 1.536 MHz
- **Resolution:**   240x224, 4096 colors
- **Aspect Ratio:** 15:14
- **Orientation:**  Horizontal

## Compatible Platforms

- Analogue Pocket

## Compatible Games

> **ROMs NOT INCLUDED:** By using this gateware you agree to provide your own roms.

| **Game**                        | Region | Status |
| :------------------------------ | :----: | :----: |
| Green Beret                     |  JPN   |   ✅   |
| Rush'n Attack                   |  USA   |   ✅   |
| Mr. Goemon                      |  JPN   |   ✅   |

### ROM Instructions

1. Download and Install [ORCA](https://github.com/opengateware/tools-orca/releases/latest) (Open ROM Conversion Assistant)
2. Download the [ROM Recipes](https://github.com/opengateware/arcade-gberet/releases/latest) and extract to your computer.
3. Copy the required MAME `.zip` file(s) into the `roms` folder.
4. Inside the `tools` folder execute the script related to your system.
   1. **Windows:** right click `make_roms.ps1` and select `Run with Powershell`.
   2. **Linux and MacOS:** run script `make_roms.sh`.
5. After the conversion is completed, copy the `Assets` folder to the Root of your SD Card.
6. **Optional:** an `.md5` file is included to verify if the hash of the ROMs are valid. (eg: `md5sum -c checklist.md5`)

> **Note:** Make sure your `.rom` files are in the `Assets/gberet/common` directory.

## Status of Features

> **WARNING**: This repository is in active development. There are no guarantees about stability. Breaking changes might occur until a stable release is made and announced.

- [x] Dip Switches
- [x] Pause
- [ ] Hi-Score Save

## Credits and acknowledgment

- [Alan Steremberg](https://github.com/alanswx)
- [Daniel Wallner](https://opencores.org/projects/t80)
- [Jim Gregory](https://github.com/JimmyStones)
- [Kuba Winnicki](https://github.com/blackwine)
- [MiSTer-X]
- [Murray Aickin](https://github.com/Mazamars312)

## Powered by Open-Source Software

This project borrowed and use code from several other projects. A great thanks to their efforts!

| Modules                        | Copyright/Developer     |
| :----------------------------- | :---------------------- |
| [Green Beret RTL]              | 2013 (c) MiSTer-X       |
| [Data Loader]                  | 2022 (c) Adam Gastineau |
| [T80]                          | 2001 (c) Daniel Wallner |

## Legal Notices

Green Beret, Rush'n Attack © 1985 Konami. Mr. Goemon © 1986 Konami. All rights reserved.
All other trademarks, logos, and copyrights are property of their respective owners.

The authors and contributors or any of its maintainers are in no way associated with or endorsed by Konami.

[Green Beret]: https://en.wikipedia.org/wiki/Rush%27n_Attack
[Data Loader]: https://github.com/agg23/analogue-pocket-utils
[Green Beret RTL]: https://github.com/MiSTer-devel/Arcade-RushnAttack_MiSTer/tree/master/rtl
[T80]: https://opencores.org/projects/t80

[MiSTer-X]: https://github.com/MrX-8B
