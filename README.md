# ChemVista

ChemVista is an iOS app built for students who want to actually *understand* organic chemistry, not just memorise it. The idea came from a frustration that's pretty common - molecules are three-dimensional structures, but we learn them through flat textbook diagrams and naming rules with no real intuition behind them. ChemVista tries to close that gap by letting you visualise, build, and interact with molecules directly - and even place them in the real world through Augmented Reality.

The goal is simple: make chemistry something you understand by experiencing it, not something you push through by memorising.

---

## The Problem

Most students don't struggle with organic chemistry because it's too complex - they struggle because it's invisible. Molecules are inherently three-dimensional, but classrooms teach them through flat diagrams and lists of rules to memorise. Students can recite naming conventions without having any real sense of what a molecule actually looks like or why it's built the way it is. This disconnect makes chemistry feel harder than it needs to be, and it leaves a lot of learners behind.

The gap isn't in their ability. It's in how the subject is presented.

## How ChemVista Solves It

ChemVista replaces passive memorisation with active exploration. Every concept in the app is tied to something you can see and interact with - a real 3D molecule you can rotate, build, zoom into, or place in your room through AR. Instead of being told what a chain of carbon atoms looks like, you construct one yourself and watch the IUPAC name update in real time. Instead of imagining bond angles from a diagram, you can hold the molecule in front of you with your camera.

This approach shifts chemistry from something abstract and text-based to something spatial and intuitive. Students build genuine understanding because they're engaging with the material the way it actually exists - in three dimensions.

---

## What the App Offers

### Learn

Two guided modules walk you through the fundamentals step by step.

**Module 1 – IUPAC Naming** takes you through the logic of how organic compounds get their names. Each step pairs a naming rule with a live 3D molecule, a clear explanation, and a worked example. You move through at your own pace, and at any point you can launch the current molecule into AR.

**Module 2 – Explore Structure** focuses on how carbon forms bonds and how molecular structures are built up, again using a step-by-step slideshow with a 3D model that updates as you progress.

### Visualize

A free-form molecule builder where you add and remove carbon and hydrogen atoms and watch the structure update live in 3D. The app shows you the IUPAC name and chemical formula as you build. When you're ready, you can throw it into AR and walk around it.

### Practice

Three quiz levels - Beginner, Intermediate, and Advanced - covering alkanes, alkenes, alkynes, branched structures, and functional groups. Each quiz shows you a molecule and asks you to identify it. You get a score and percentage at the end, and you can view any quiz molecule in AR mid-session.

### Finder

A searchable library of organic compounds displayed in a clean grid. Search by name or formula, tap any compound to see its 3D structure, and open a details sheet with everything from molar mass and bond angles to real-world uses and physical properties. Every compound in the library can be launched into AR from its detail view.

### Augmented Reality

AR runs through the entire app. Wherever you are - learning a naming rule, building a molecule, taking a quiz, or browsing the library - you can place the current molecule into your real environment using your camera. It supports pinch to scale, drag to rotate, and tap to reposition.

---

## Who It's For

ChemVista is built with visual learners in mind - students who find it hard to build an intuition for molecular structure from diagrams alone. It's also useful as a teaching aid for educators who want something more interactive than a whiteboard.

---

## Running the App

Open `ChemVista.swiftpm` in Swift Playgrounds 4 on iPad or in Xcode on Mac. No external dependencies.

---

## Accessibility

Navigation is intentionally simple, typography is readable, and contrast is strong throughout. All interactive elements have VoiceOver labels and hints, decorative visuals are hidden from the accessibility tree, and concepts are introduced one step at a time to avoid overwhelming users. The app also avoids unnecessary motion.

---

## Author

Built by Shailesh - February 2026.
