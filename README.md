# 🎶 Music Player 🎶
This repo contains an implementation of a music player using HCS12 assembly language on an [MC9S12DT256 Freescale microcontroller](https://html.alldatasheet.com/html-pdf/126901/FREESCALE/MC9S12DT256/490/1/MC9S12DT256.html), interfaced with [CSMB12](https://www.axman.com/content/csmb12-module) and mounted on the [PBMCUSLK board](https://www.nxp.com/pages/mcu-project-board:PBMCUSLK).

## Description 
The buzzer component of the PBMCUSLK board plays parts of two distinctive songs. The chosen songs are *Au Clair de la Lune* and *I Love You (by Barney)*. 

## Features
The following are the set of features corresponding to this project:
- The user can choose to play any of the two songs using two push buttons, each corresponding to one the two songs.
- The lyrics of the corresponding song are displayed on the LCD of the PBMCUSLK board. 
- LEDs are toggled following the notes of each song. For every note, the following LED toggling combination were used, which turn on at the beginning of the note and turns off when the note ends:
  - Do: LEDs 2 and 4 are turned on
  - Re: LEDs 1 and 3 are turned on
  - Mi: LEDs 1 and 4 are turned on
  - Fa: LEDs 2 and 3 are turned on
  - Sol: LEDs 3 and 4 are turned on
  - La: LEDs 1 and 2 are turned on
  - Si: LEDs 2, 3 and 4 are turned on
- If the other push button is pressed, the other song starts playing.
- Pressing the same push button again restarts the song. The LEDs will refresh their blinking and the LCD will reset the lyrics. 

## Components
The following components of the CSMB12 and the PBMCUSLK board were used:
- Buzzer
- LCD
- Four LEDs
- Two push buttons

## Hardware
- CSMB12 
- PBMCUSLK

## Software 
- CodeWarrior IDE
 
***Note**: Two additional colleagues are contributors to this project.*

## Video Demos
[Au Clair de la Lune](https://user-images.githubusercontent.com/92987443/173164341-d5f707db-d3e3-4a12-8fcc-83835466c913.mp4)

[I Love You (by Barney)](https://user-images.githubusercontent.com/92987443/173164455-879d14c0-682d-441c-bd38-fb33f932983c.mp4)


