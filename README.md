# Half Keyboard

<img src="./HalfKeyboard/Assets.xcassets/AppIcon.appiconset/Mac%20App%20128pt@2x.png" width=128 alt="Half Keyboard app icon" />

This is a proof-of-concept app that lets you type more easily with one hand on a Mac. It was inspired by the concept of a [half-QWERTY keyboard](https://www.billbuxton.com/matias93.html), plus the need to be able to type with one hand while [holding a baby](https://twitter.com/zeveisenberg/status/1268585275346898950). If you often find yourself typing with one hand, this app may be useful to you.

## Usage

There’s no binary, so you have to build from source. You also need to grant accessibility permissions for the app to work. It currently doesn’t have any UI for this, but if you’re using Catalina or later, you know what’s up. ⚠️ **You will have to relaunch the app after enabling permissions.**

The app works by mirroring the keyboard left-to-right when the spacebar is held down. After enabling the app, put one hand on the keyboard and type normally. When you would use the other hand, simply hold the spacebar while making the equivalent motion with the hand that's on the keyboard. Try it for a few minutes and you should get the hang of it. Try it for a few hours and you’ll probably be able to touch-type.

Once enabled, the app enables half-keyboard mode system-wide. If there is an app that doesn’t work, please file an issue.

## Current State

This is a rough proof-of-concept that I threw together in a few hours. I got the some keyboard event tap code from [Unshaky](https://github.com/aahung/Unshaky) and ported it to Swift.

There are some non-letter keys that are poorly supported or unsupported. See code comments for details. There are also some bugs, such as the inability to use certain keyboard shortcuts that involve the spacebar. But basic typing should work, and depending on which hand you use, it could already be useful to you as a coder or writer. If you notice a bug or missing letter, please file a bug so we can track what needs to be done.

The app has been tested only with a US-English QWERTY layout. It shouldn’t be too hard to add other layout support, though. You’d have to add another mapping table in code, and figure out a way to select the mapping table based on the system’s currently selected keyboard layout.

## Future

It would be great to add a real UI and tutorial. But even better, it would be great if operating system venders added this as an accessibility feature. I’m releasing it under the MIT license in the hopes that they (or a third party) will take the idea and run with it. It’s easy enough to run it as an app, but building it into the system would be pretty slick.

(If you decide to do this, you might want to check with [Matias](https://matias.ca/halfkeyboard/) to see if they have any annoying patents or copyrights. The [original patent](https://patents.google.com/patent/EP0489792B1) appears to have expired in 2010, but I am not a lawyer.)

## Credits
Icon uses assets created by Herbert Spencer from the Noun Project.
